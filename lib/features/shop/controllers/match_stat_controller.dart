import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/match stats/match_stats_repository.dart';
import '../../../data/repositories/matches/matches_repository.dart';
import '../../../data/services/notifications/notification_service.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/match_stats_model.dart';
import '../screens/live streaming pedro/presentation/controllers/streaming_coordinator.dart';
import 'live_updates_controller.dart';


class MatchStatsController extends GetxController {
  static MatchStatsController get instance => Get.find();

  final isLoading = false.obs;
  final matchStatsRepository = Get.put(MatchStatsRepository());

  // ── Per-match state (keyed by matchId) ──
  final RxMap<String, String> _currentPlayers = <String, String>{}.obs;
  final Map<String, int> _player1Breaks = {};
  final Map<String, int> _player2Breaks = {};
  final Map<String, bool> _breakNotified = {};
  Map<String, int> debugBreaks() => Map.from(_player1Breaks);// per match break notification flag

  RxList<MatchStatsModel> frames = <MatchStatsModel>[].obs;
  Rx<MatchStatsModel?> currentFrame = Rx<MatchStatsModel?>(null);

  StreamSubscription? _framesSubscription;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PER-MATCH STATE HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  String getCurrentPlayer(String matchId) => _currentPlayers[matchId] ?? 'player1';

  int getPlayer1Break(String matchId) => _player1Breaks[matchId] ?? 0;
  int getPlayer2Break(String matchId) => _player2Breaks[matchId] ?? 0;

  void _setPlayer1Break(String matchId, int value) => _player1Breaks[matchId] = value;
  void _setPlayer2Break(String matchId, int value) => _player2Breaks[matchId] = value;

  // ── Convenience getters for current frame's match ──
  String get _matchId => currentFrame.value?.matchId ?? '';
  int get player1CurrentBreak => _player1Breaks[_matchId] ?? 0;
  int get player2CurrentBreak => _player2Breaks[_matchId] ?? 0;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<MatchRepository>()) {
      Get.put(MatchRepository());
    }
  }

  @override
  void onClose() {
    _framesSubscription?.cancel();
    super.onClose();
  }
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WATCH FRAMES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void watchMatchFrames(String matchId) {
    debugPrint('🎱 Starting watch for matchId: $matchId');
    _framesSubscription?.cancel();

    _framesSubscription = matchStatsRepository.watchFramesByMatch(matchId).listen(
          (framesList) {
        debugPrint('📊 Received ${framesList.length} frames');
        frames.assignAll(framesList);
        final incomplete = framesList.where((f) => f.winnerId == null).toList();
        currentFrame.value = incomplete.isNotEmpty ? incomplete.last : null;
      },
      onError: (e, stack) {
        debugPrint('❌ Stream error: $e');
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'watchMatchFrames stream error');
      },
    );
  }

  void stopWatchingFrames() => _framesSubscription?.cancel();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ADD BALL
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> addBall(String ballColor, int ballValue) async {
    try {
      final frame = currentFrame.value;
      if (frame == null) {
        debugPrint('⚠️ addBall: no current frame');
        return;
      }

      final matchId = frame.matchId;
      final isPlayer1 = getCurrentPlayer(matchId) == 'player1';

      if (isPlayer1) {
        frame.player1BallSequence = List<String>.from(frame.player1BallSequence)..add(ballColor);
        frame.player1Points += ballValue;
        _setPlayer1Break(matchId, (getPlayer1Break(matchId)) + ballValue);

        if (getPlayer1Break(matchId) > frame.player1HighestBreak) {
          frame.player1HighestBreak = getPlayer1Break(matchId);
        }
      } else {
        frame.player2BallSequence = List<String>.from(frame.player2BallSequence)..add(ballColor);
        frame.player2Points += ballValue;
        _setPlayer2Break(matchId, (getPlayer2Break(matchId)) + ballValue);

        if (getPlayer2Break(matchId) > frame.player2HighestBreak) {
          frame.player2HighestBreak = getPlayer2Break(matchId);
        }
      }

      currentFrame.value = frame;
      currentFrame.refresh();

      debugPrint('🎱 addBall done — checking coordinator for matchId: $matchId');
      debugPrint('🎱 isRegistered: ${Get.isRegistered<StreamingCoordinator>(tag: matchId)}');
      debugPrint('🎱 p1Break: ${getPlayer1Break(matchId)}');
      currentFrame.refresh();
      if (Get.isRegistered<StreamingCoordinator>(tag: matchId)) {
        Get.find<StreamingCoordinator>(tag: matchId).updateScoreboard();
      }

      // Save in background — don't await to keep UI responsive
      matchStatsRepository.updateItem(frame).catchError((e) {
        debugPrint('❌ updateItem error: $e');
        FirebaseCrashlytics.instance.recordError(e, null, reason: 'addBall updateItem failed');
      });

      MatchRepository.instance.updateSingleField(frame.matchId, {
        'player1CurrentPoints': frame.player1Points,
        'player2CurrentPoints': frame.player2Points,
      }).catchError((e) {
        debugPrint('❌ updateSingleField error: $e');
      });

    } catch (e, stack) {
      debugPrint('❌ Add ball error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'addBall failed');
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SWITCH PLAYER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // In MatchStatsController.switchPlayer() — call updateScoreboard BEFORE resetting break

  Future<void> switchPlayer({
    required String matchId,
    required String playerName,
  }) async {
    try {
      final isPlayer1 = getCurrentPlayer(matchId) == 'player1';
      final currentBreak = isPlayer1 ? getPlayer1Break(matchId) : getPlayer2Break(matchId);

      // Notify if break >= 50
      if (currentBreak >= 50) {
        final notifyKey = '${matchId}_${isPlayer1 ? 'p1' : 'p2'}';
        if (_breakNotified[notifyKey] != true) {
          _breakNotified[notifyKey] = true;
          await TNotificationService.instance.sendToTopic(
            topic: 'all_users',
            title: '🔥 High Break - $currentBreak!',
            body: '$playerName scored a $currentBreak break!',
            data: {'type': 'high_break', 'matchId': matchId, 'score': currentBreak.toString()},
          );
        }
      }

      // Live update for break if worthy
      if (currentBreak >= 50) {
        final frame = currentFrame.value;
        if (frame != null) {
          LiveUpdatesController.instance.addHighBreak(
            playerName, '', frame.frameNumber.toString(), currentBreak,
          );
        }
      }

      // Switch player
      if (isPlayer1) {
        _setPlayer1Break(matchId, 0);
        _breakNotified['${matchId}_p1'] = false;
        _currentPlayers[matchId] = 'player2';
      } else {
        _setPlayer2Break(matchId, 0);
        _breakNotified['${matchId}_p2'] = false;
        _currentPlayers[matchId] = 'player1';
      }

      // Update scoreboard AFTER switching so active player is correct, break already reset
      // But we need to show the NEW break (0 after switch) — this is correct
      if (Get.isRegistered<StreamingCoordinator>(tag: matchId)) {
        Get.find<StreamingCoordinator>(tag: matchId).updateScoreboard();
      }

      debugPrint('🔄 Switched to ${getCurrentPlayer(matchId)} for match $matchId');
    } catch (e, stack) {
      debugPrint('❌ switchPlayer error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'switchPlayer failed');
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UNDO BALL
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void undoBall() {
    try {
      final frame = currentFrame.value;
      if (frame == null) return;

      final matchId = frame.matchId;
      final isPlayer1 = getCurrentPlayer(matchId) == 'player1';

      List<String> sequence;
      int currentPoints;
      int currentBreak;

      if (isPlayer1) {
        sequence = List<String>.from(frame.player1BallSequence);
        currentPoints = frame.player1Points;
        currentBreak = getPlayer1Break(matchId);
      } else {
        sequence = List<String>.from(frame.player2BallSequence);
        currentPoints = frame.player2Points;
        currentBreak = getPlayer2Break(matchId);
      }

      if (sequence.isEmpty) return;

      final lastBall = sequence.last;
      final ballValue = _getBallValue(lastBall);

      sequence.removeLast();
      currentPoints -= ballValue;
      currentBreak = (currentBreak - ballValue).clamp(0, 999);

      if (isPlayer1) {
        frame.player1BallSequence = sequence;
        frame.player1Points = currentPoints;
        _setPlayer1Break(matchId, currentBreak);
      } else {
        frame.player2BallSequence = sequence;
        frame.player2Points = currentPoints;
        _setPlayer2Break(matchId, currentBreak);
      }

      currentFrame.value = frame;
      currentFrame.refresh();

      matchStatsRepository.updateItem(frame).catchError((e) {
        debugPrint('❌ undo updateItem error: $e');
      });

      MatchRepository.instance.updateSingleField(frame.matchId, {
        'player1CurrentPoints': frame.player1Points,
        'player2CurrentPoints': frame.player2Points,
      }).catchError((e) {
        debugPrint('❌ undo updateSingleField error: $e');
      });

    } catch (e, stack) {
      debugPrint('❌ Undo error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'undoBall failed');
    }
  }

  int _getBallValue(String ballColor) {
    switch (ballColor.toLowerCase()) {
      case 'red': return 1;
      case 'yellow': return 2;
      case 'green': return 3;
      case 'brown': return 4;
      case 'blue': return 5;
      case 'pink': return 6;
      case 'black': return 7;
      default: return 0;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // RESET FRAME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void resetFrame() {
    Get.defaultDialog(
      title: 'Reset Frame',
      middleText: 'This will reset all scores and balls for this frame. This cannot be undone.',
      confirm: ElevatedButton(
        onPressed: () async {
          Navigator.of(Get.overlayContext!).pop();
          try {
            final frame = currentFrame.value;
            if (frame == null) return;

            final matchId = frame.matchId;

            frame.player1Points = 0;
            frame.player2Points = 0;
            frame.player1BallSequence = [];
            frame.player2BallSequence = [];
            frame.player1HighestBreak = 0;
            frame.player2HighestBreak = 0;

            _setPlayer1Break(matchId, 0);
            _setPlayer2Break(matchId, 0);
            _breakNotified['${matchId}_p1'] = false;
            _breakNotified['${matchId}_p2'] = false;

            currentFrame.value = frame;
            currentFrame.refresh();

            await matchStatsRepository.updateItem(frame);
            await MatchRepository.instance.updateSingleField(frame.matchId, {
              'player1CurrentPoints': 0,
              'player2CurrentPoints': 0,
            });

            debugPrint('✅ Frame reset');
          } catch (e, stack) {
            debugPrint('❌ Reset error: $e');
            FirebaseCrashlytics.instance.recordError(e, stack, reason: 'resetFrame failed');
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('Reset'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COMPLETE FRAME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> completeFrame(String matchId, int frameNumber, String winnerId) async {
    try {
      await matchStatsRepository.updateSingleField(matchId, frameNumber, {
        'winnerId': winnerId,
        'completedAt': DateTime.now().millisecondsSinceEpoch,
      });

      final allFrames = await matchStatsRepository.fetchFramesByMatch(matchId);
      final match = await MatchRepository.instance.fetchSingleItem(matchId);

      final p1Wins = allFrames.where((f) => f.winnerId == match.player1Id).length;
      final p2Wins = allFrames.where((f) => f.winnerId == match.player2Id).length;

      await MatchRepository.instance.updateSingleField(matchId, {
        'player1FramesWon': p1Wins,
        'player2FramesWon': p2Wins,
        'player1CurrentPoints': 0,
        'player2CurrentPoints': 0,
      });

      // Reset per-match breaks and player
      _setPlayer1Break(matchId, 0);
      _setPlayer2Break(matchId, 0);
      _breakNotified['${matchId}_p1'] = false;
      _breakNotified['${matchId}_p2'] = false;
      _currentPlayers[matchId] = 'player1';

      final winnerPlayer = await UserController.instance.getUserById(winnerId);

      LiveUpdatesController.instance.addFrameWinner(
        winnerPlayer.firstName,
        winnerPlayer.profilePicture.isEmpty
            ? 'assets/images/players/default.jpg'
            : winnerPlayer.profilePicture,
        frameNumber.toString(),
        '$p1Wins - $p2Wins',
      );



      debugPrint('✅ Frame $frameNumber completed. Winner: $winnerId');
    } catch (e, stack) {
      debugPrint('❌ Complete frame error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'completeFrame failed');
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FETCH / ADD / UPDATE / DELETE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> fetchFramesByMatch(String matchId) async {
    try {
      isLoading.value = true;
      final framesList = await matchStatsRepository.fetchFramesByMatch(matchId);
      frames.assignAll(framesList);
    } catch (e, stack) {
      debugPrint('❌ Fetch frames error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'fetchFramesByMatch failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<MatchStatsModel?> getFrame(String matchId, int frameNumber) async {
    try {
      return await matchStatsRepository.fetchSingleItem(matchId, frameNumber);
    } catch (e, stack) {
      debugPrint('❌ Get frame error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'getFrame failed');
      return null;
    }
  }

  Future<void> addFrame(MatchStatsModel frame) async {
    try {
      await matchStatsRepository.addItem(frame);
      debugPrint('✅ Frame added');
    } catch (e, stack) {
      debugPrint('❌ Add frame error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'addFrame failed');
    }
  }

  Future<void> updateFrame(MatchStatsModel frame) async {
    try {
      await matchStatsRepository.updateItem(frame);

      // Only update match currentPoints if this is the active frame
      final isCurrentFrame = currentFrame.value?.frameNumber == frame.frameNumber;
      if (isCurrentFrame) {
        await MatchRepository.instance.updateSingleField(frame.matchId, {
          'player1CurrentPoints': frame.player1Points,
          'player2CurrentPoints': frame.player2Points,
        });
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
  Future<void> deleteFrame(MatchStatsModel frame) async {
    try {
      await matchStatsRepository.deleteItem(frame);
    } catch (e, stack) {
      debugPrint('❌ Delete frame error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'deleteFrame failed');
    }
  }
}