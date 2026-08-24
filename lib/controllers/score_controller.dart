import 'package:get/get.dart';

/// Holds active player, running scores (current frame), break tracking,
/// and undo history. Frame/match-level state lives in
/// FrameTrackingController and MatchResultController instead.
class ScoreController extends GetxController {
  // ---------------- Active player ----------------
  final RxInt activePlayer = 1.obs;

  void setActivePlayer(int player) {
    if (player == activePlayer.value) return;
    _finalizeBreakForActivePlayer();
    activePlayer.value = player;
  }

  void toggleActivePlayer() {
    _finalizeBreakForActivePlayer();
    activePlayer.value = activePlayer.value == 1 ? 2 : 1;
  }

  bool isActive(int player) => activePlayer.value == player;

  /// Public wrapper so other controllers (FrameTrackingController) can
  /// finalize the current break without needing a private method call.
  void finalizeCurrentBreak() => _finalizeBreakForActivePlayer();

  void _finalizeBreakForActivePlayer() {
    if (activePlayer.value == 1) {
      if (side1CurrentBreak.value > side1HighestBreak.value) {
        side1HighestBreak.value = side1CurrentBreak.value;
      }
      side1CurrentBreak.value = 0;
    } else {
      if (side2CurrentBreak.value > side2HighestBreak.value) {
        side2HighestBreak.value = side2CurrentBreak.value;
      }
      side2CurrentBreak.value = 0;
    }
  }

  /// Who broke first this match — set once via BreakingPlayerSheet.
  /// Fixes which side always renders on the left in the UI.
  final RxnInt breakingPlayer = RxnInt();

  void setBreakingPlayer(int player) {
    breakingPlayer.value = player;
    activePlayer.value = player;
  }

  // ---------------- Match started state ----------------
  final RxBool isMatchStarted = false.obs;

  void toggleMatchStarted() => isMatchStarted.value = !isMatchStarted.value;

  // ---------------- Running scores (current frame) ----------------
  final RxInt side1Score = 0.obs;
  final RxInt side2Score = 0.obs;

  // ---------------- Break tracking (current frame) ----------------
  final RxInt side1CurrentBreak = 0.obs;
  final RxInt side2CurrentBreak = 0.obs;
  final RxInt side1HighestBreak = 0.obs;
  final RxInt side2HighestBreak = 0.obs;

  /// Undo history — each entry records (which side, how many points).
  final List<ScoreAction> history = [];

  /// Adds points to whichever side is currently active (ball taps in
  /// Snooker). Caller (ScoringScreen) checks isFrameActive before calling.
  void addPointsToActive(int points) {
    if (activePlayer.value == 1) {
      side1Score.value += points;
      side1CurrentBreak.value += points;
      if (side1CurrentBreak.value > side1HighestBreak.value) {
        side1HighestBreak.value = side1CurrentBreak.value;
      }
    } else {
      side2Score.value += points;
      side2CurrentBreak.value += points;
      if (side2CurrentBreak.value > side2HighestBreak.value) {
        side2HighestBreak.value = side2CurrentBreak.value;
      }
    }
    history.add(ScoreAction(side: activePlayer.value, points: points));
  }

  void incrementSide1() {
    side1Score.value++;
    history.add(const ScoreAction(side: 1, points: 1));
  }

  void decrementSide1() {
    if (side1Score.value > 0) side1Score.value--;
  }

  void incrementSide2() {
    side2Score.value++;
    history.add(const ScoreAction(side: 2, points: 1));
  }

  void decrementSide2() {
    if (side2Score.value > 0) side2Score.value--;
  }

  void undo() {
    if (history.isEmpty) return;
    final last = history.removeLast();
    if (last.side == 1) {
      side1Score.value = (side1Score.value - last.points).clamp(0, 999);
    } else {
      side2Score.value = (side2Score.value - last.points).clamp(0, 999);
    }
  }

  /// Resets current frame's scores AND break tracking back to zero.
  void resetCurrentFrame() {
    side1Score.value = 0;
    side2Score.value = 0;
    side1CurrentBreak.value = 0;
    side2CurrentBreak.value = 0;
    side1HighestBreak.value = 0;
    side2HighestBreak.value = 0;
    history.clear();
  }
}

class ScoreAction {
  final int side;
  final int points;

  const ScoreAction({required this.side, required this.points});
}