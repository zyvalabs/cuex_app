import 'package:cuex_app/controllers/score%20sync/sync_mode_contoller.dart';
import 'package:get/get.dart';
import '../../repositories/local/score_local_storage_service.dart';
import '../frame_tracking_controller.dart';
import '../match_result_conrollers.dart';
import '../score_controller.dart';


/// Owns all save/load/sync orchestration for a scoring session — pure
/// logic, no UI. ScoringScreen just calls loadForMatch() once and
/// persist() after any user action; this controller handles the rest
/// (local storage + pushing through whichever sync transport is active).
class ScoringPersistenceController extends GetxController {
  final ScoreController score = Get.isRegistered<ScoreController>() ? Get.find<ScoreController>() : Get.put(ScoreController());
  final FrameTrackingController frames = Get.isRegistered<FrameTrackingController>()
      ? Get.find<FrameTrackingController>()
      : Get.put(FrameTrackingController());
  final MatchResultController result = Get.isRegistered<MatchResultController>()
      ? Get.find<MatchResultController>()
      : Get.put(MatchResultController());
  final SyncModeController syncMode =
  Get.isRegistered<SyncModeController>() ? Get.find<SyncModeController>() : Get.put(SyncModeController());

  final ScoreLocalStorageService _storage = ScoreLocalStorageService();

  String? _matchId;

  /// Call once when ScoringScreen opens — loads any previously saved
  /// session for this matchId, or starts fresh if nothing was saved yet.
  Future<void> loadForMatch(String matchId) async {
    _matchId = matchId;
    await _storage.load(matchId, score: score, frames: frames, result: result);
  }

  /// Saves current state to local storage AND pushes it through the
  /// active sync transport (RTDB by default). Call this after any user
  /// action that changes scoring/frame/match state. No-op if matchId
  /// hasn't been set yet (loadForMatch wasn't called or was passed null).
  void persist() {
    if (_matchId == null) return;

    // ignore: avoid_print
    print('🟣 [ScoringPersistenceController] persist() called for $_matchId');

    _storage.save(_matchId!, score: score, frames: frames, result: result);

    final syncJson = {
      'activePlayer': score.activePlayer.value,
      'breakingPlayer': score.breakingPlayer.value,
      'isMatchStarted': score.isMatchStarted.value,
      'side1Score': score.side1Score.value,
      'side2Score': score.side2Score.value,
      'side1HighestBreak': score.side1HighestBreak.value,
      'side2HighestBreak': score.side2HighestBreak.value,
      'currentFrameNumber': frames.currentFrameNumber.value,
      'side1FramesWon': frames.side1FramesWon.value,
      'side2FramesWon': frames.side2FramesWon.value,
      'isFrameActive': frames.isFrameActive.value,
      'completedFrames': frames.completedFrames
          .map((f) => {
        'frameNumber': f.frameNumber,
        'side1Score': f.side1Score,
        'side2Score': f.side2Score,
        'side1Break': f.side1Break,
        'side2Break': f.side2Break,
        'winningSide': f.winningSide,
      })
          .toList(),
      'matchWinner': result.matchWinner.value,
      'isMatchEnded': result.isMatchEnded.value,
    };

    syncMode.sendUpdate(_matchId!, syncJson);
  }
}