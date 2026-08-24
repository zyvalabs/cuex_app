import 'package:get/get.dart';
import 'score_controller.dart';
import 'frame_tracking_controller.dart';

/// Holds match-level result state — winner and whether the match has ended.
/// Coordinates with ScoreController and FrameTrackingController when
/// "End Match" is confirmed.
class MatchResultController extends GetxController {
  final RxnInt matchWinner = RxnInt();
  final RxBool isMatchEnded = false.obs;

  /// Called when "End Match" is confirmed via MatchWinnerSheet.
  /// If a frame is still in progress, finalizes it first (using current
  /// scores) so it's not left orphaned.
  void endMatch({
    required int winningSide,
    required ScoreController scoreController,
    required FrameTrackingController frameTracking,
  }) {
    if (frameTracking.isFrameActive.value) {
      frameTracking.endFrame(scoreController);
    }
    matchWinner.value = winningSide;
    isMatchEnded.value = true;
    scoreController.isMatchStarted.value = false;
  }
}