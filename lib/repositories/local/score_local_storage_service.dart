import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/frame_tracking_controller.dart';
import '../../controllers/match_result_conrollers.dart';
import '../../controllers/score_controller.dart';


/// Saves/loads the combined state of all 3 scoring controllers to local
/// device storage — keyed by matchId, so state survives app kill/restart
/// on the SAME device. For a second device (e.g. someone viewing the
/// match from a different phone/account), local storage won't have
/// anything — that's what applyJsonToControllers + RTDB remote sync
/// (via RtdbSyncService) is for instead.
class ScoreLocalStorageService {
  String _keyFor(String matchId) => 'score_session_$matchId';

  Future<void> save(
      String matchId, {
        required ScoreController score,
        required FrameTrackingController frames,
        required MatchResultController result,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(matchId), jsonEncode(buildJson(score: score, frames: frames, result: result)));
  }

  /// Loads a previously saved LOCAL session — only exists on the device
  /// that actually scored the match. Returns the raw json map (or null)
  /// so the caller can decide what to do if nothing's found locally
  /// (e.g. fall back to fetching from RTDB instead).
  Future<Map<String, dynamic>?> loadRaw(String matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(matchId));
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clear(String matchId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(matchId));
  }

  /// Builds the shared JSON shape from the 3 controllers — used for both
  /// local save AND the RTDB sync payload, so both stay in the exact
  /// same format and applyJsonToControllers can parse either one.
  static Map<String, dynamic> buildJson({
    required ScoreController score,
    required FrameTrackingController frames,
    required MatchResultController result,
  }) {
    return {
      'activePlayer': score.activePlayer.value,
      'breakingPlayer': score.breakingPlayer.value,
      'isMatchStarted': score.isMatchStarted.value,
      'side1Score': score.side1Score.value,
      'side2Score': score.side2Score.value,
      'side1CurrentBreak': score.side1CurrentBreak.value,
      'side2CurrentBreak': score.side2CurrentBreak.value,
      'side1HighestBreak': score.side1HighestBreak.value,
      'side2HighestBreak': score.side2HighestBreak.value,
      'bestOfFrames': frames.bestOfFrames.value,
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
  }

  /// Applies a JSON map (from either local storage OR RTDB) onto the 3
  /// controllers. Shared logic so both data sources parse identically.
  static void applyJsonToControllers(
      Map<String, dynamic> json, {
        required ScoreController score,
        required FrameTrackingController frames,
        required MatchResultController result,
      }) {
    score.activePlayer.value = json['activePlayer'] ?? 1;
    score.breakingPlayer.value = json['breakingPlayer'];
    score.isMatchStarted.value = json['isMatchStarted'] ?? false;
    score.side1Score.value = json['side1Score'] ?? 0;
    score.side2Score.value = json['side2Score'] ?? 0;
    score.side1CurrentBreak.value = json['side1CurrentBreak'] ?? 0;
    score.side2CurrentBreak.value = json['side2CurrentBreak'] ?? 0;
    score.side1HighestBreak.value = json['side1HighestBreak'] ?? 0;
    score.side2HighestBreak.value = json['side2HighestBreak'] ?? 0;

    frames.bestOfFrames.value = json['bestOfFrames'] ?? 5;
    frames.currentFrameNumber.value = json['currentFrameNumber'] ?? 1;
    frames.side1FramesWon.value = json['side1FramesWon'] ?? 0;
    frames.side2FramesWon.value = json['side2FramesWon'] ?? 0;
    frames.isFrameActive.value = json['isFrameActive'] ?? false;

    final framesJson = json['completedFrames'] as List<dynamic>? ?? [];
    frames.completedFrames.value = framesJson
        .map((f) => FrameResult(
      frameNumber: f['frameNumber'],
      side1Score: f['side1Score'],
      side2Score: f['side2Score'],
      side1Break: f['side1Break'],
      side2Break: f['side2Break'],
      winningSide: f['winningSide'],
    ))
        .toList();

    result.matchWinner.value = json['matchWinner'];
    result.isMatchEnded.value = json['isMatchEnded'] ?? false;
  }
}