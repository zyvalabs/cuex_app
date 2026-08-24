import 'package:get/get.dart';
import 'score_controller.dart';

/// Holds frame-level tracking — current frame number, frames won per side,
/// completed frame history, and start/end frame logic. Reads/resets
/// ScoreController's running scores when a frame starts/ends.
class FrameTrackingController extends GetxController {
  /// Best-of-X target — e.g. 5 means first to 3 frames wins the match.
  final RxInt bestOfFrames = 5.obs;

  final RxInt currentFrameNumber = 1.obs;
  final RxInt side1FramesWon = 0.obs;
  final RxInt side2FramesWon = 0.obs;

  final RxBool isFrameActive = false.obs;

  /// Records of each completed frame — scores, winner, and highest break
  /// per side, so the FrameHistoryTable can show a real breakdown.
  final RxList<FrameResult> completedFrames = <FrameResult>[].obs;

  void startFrame() {
    isFrameActive.value = true;
  }

  /// Ends the current frame using scores from the given ScoreController.
  /// If both scores are 0-0 (accidental start), the frame is discarded
  /// entirely — not recorded, frame number doesn't advance.
  void endFrame(ScoreController scoreController) {
    if (scoreController.side1Score.value == 0 && scoreController.side2Score.value == 0) {
      isFrameActive.value = false;
      return; // discarded
    }

    scoreController.finalizeCurrentBreak(); // lock in the last turn's break

    int? winningSide;
    if (scoreController.side1Score.value > scoreController.side2Score.value) {
      winningSide = 1;
      side1FramesWon.value++;
    } else if (scoreController.side2Score.value > scoreController.side1Score.value) {
      winningSide = 2;
      side2FramesWon.value++;
    }

    completedFrames.add(FrameResult(
      frameNumber: currentFrameNumber.value,
      side1Score: scoreController.side1Score.value,
      side2Score: scoreController.side2Score.value,
      side1Break: scoreController.side1HighestBreak.value,
      side2Break: scoreController.side2HighestBreak.value,
      winningSide: winningSide,
    ));

    currentFrameNumber.value++;
    scoreController.resetCurrentFrame();
    isFrameActive.value = false;
  }

  int get framesNeededToWin => (bestOfFrames.value / 2).ceil();

  bool get isMatchWon => side1FramesWon.value >= framesNeededToWin || side2FramesWon.value >= framesNeededToWin;
}

/// Public so FrameHistoryTable can accept a List<FrameResult> directly.
class FrameResult {
  final int frameNumber;
  final int side1Score;
  final int side2Score;
  final int side1Break;
  final int side2Break;
  final int? winningSide;

  const FrameResult({
    required this.frameNumber,
    required this.side1Score,
    required this.side2Score,
    required this.side1Break,
    required this.side2Break,
    required this.winningSide,
  });
}