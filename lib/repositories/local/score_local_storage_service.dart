import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/frame_tracking_controller.dart';
import '../../controllers/match_result_conrollers.dart';
import '../../controllers/score_controller.dart';


/// Saves/loads the combined state of all 3 scoring controllers to local
/// device storage — keyed by matchId, so state survives app kill/restart.
/// This is the source of truth for the scorer's own device; Firebase RTDB
/// sync (for the streaming phone) will be layered on top later.
class ScoreLocalStorageService {
  String _keyFor(String matchId) => 'score_session_$matchId';

  Future<void> save(
      String matchId, {
        required ScoreController score,
        required FrameTrackingController frames,
        required MatchResultController result,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final json = {
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
    await prefs.setString(_keyFor(matchId), jsonEncode(json));
  }

  /// Loads a previously saved session and applies it directly onto the
  /// 3 controllers passed in. No-op if nothing was saved yet.
  Future<void> load(
      String matchId, {
        required ScoreController score,
        required FrameTrackingController frames,
        required MatchResultController result,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(matchId));
    if (raw == null) return;

    final json = jsonDecode(raw) as Map<String, dynamic>;

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

  Future<void> clear(String matchId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(matchId));
  }
}