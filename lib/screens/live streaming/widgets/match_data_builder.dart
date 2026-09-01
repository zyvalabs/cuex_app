import '../../../controllers/frame_tracking_controller.dart';
import '../../../controllers/score_controller.dart';


/// Builds the matchData map with the EXACT keys ScoreboardManager.kt
/// expects (test_ribbon.xml view IDs). Shared by GoLiveCameraScreen
/// (initial startPreview snapshot) and ScoringScreen (live updates via
/// updateScoreboard) so both always send identically-shaped data.
Map<String, dynamic> buildScoreboardMatchData({
  required ScoreController score,
  required FrameTrackingController frames,
  required String side1Name,
  required String side2Name,
  required String eventName,
  required String roundName,
  required int totalFrames,
}) {
  return {
    'player1Name': side1Name,
    'player2Name': side2Name,
    'player1Score': score.side1Score.value,
    'player2Score': score.side2Score.value,
    'matchName': eventName,
    'roundName': roundName,
    'player1FramesWon': frames.side1FramesWon.value,
    'player2FramesWon': frames.side2FramesWon.value,
    'totalFrames': totalFrames,
    'player1CurrentBreak': score.side1CurrentBreak.value,
    'player2CurrentBreak': score.side2CurrentBreak.value,
    'player1HighestBreak': score.side1HighestBreak.value,
    'player2HighestBreak': score.side2HighestBreak.value,
    'isPlayer1Active': score.isActive(1),
    'isPlayer2Active': score.isActive(2),
  };
}