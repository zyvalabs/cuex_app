import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

import '../../../../../../data/repositories/events/event_repository.dart';
import '../../../../../../data/repositories/match%20stats/match_stats_repository.dart';
import '../../../../../../data/repositories/matches/matches_repository.dart';
import '../../../../../../data/services/streaming/streaming_service.dart';
import '../../../../../personalization/controllers/user_controller.dart';
import '../../../../controllers/match_stat_controller.dart';
import '../controllers/preview_controller.dart';
import '../controllers/stream_controller.dart';
import 'audio_controller.dart';
import 'broadcast_controller.dart';
import 'camera_controller.dart';

class StreamingCoordinator extends GetxController {
  final String matchId;
  final _db = FirebaseFirestore.instance;
  final isBreakActive = false.obs;

  StreamingCoordinator({required this.matchId});

  PreviewController get previewController => Get.find<PreviewController>();
  LiveStreamController get streamController => Get.find<LiveStreamController>();
  AudioController get audioController => Get.find<AudioController>();
  CameraController get cameraController => Get.find<CameraController>();
  BroadcastController get broadcastController => Get.find<BroadcastController>();

  // ─────────────────────────────────────────
  // Build Match Data — null-safe for practice
  // ─────────────────────────────────────────

  Future<Map<String, dynamic>> buildMatchData() async {
    try {
      dev.log('🔨 Building match data for matchId: $matchId');

      final statsController = Get.isRegistered<MatchStatsController>()
          ? Get.find<MatchStatsController>()
          : Get.put(MatchStatsController());

      final match = await MatchRepository.instance.fetchSingleItem(matchId);

      // ✅ null-safe player names — fallback to match.player1Name for practice
      String p1Name = match.player1Name ?? 'Player 1';
      String p2Name = match.player2Name ?? 'Player 2';

      if (match.player1Id != null && match.player1Id!.isNotEmpty) {
        try {
          final p1 = await UserController.instance.getUserById(match.player1Id!);
          final name = '${p1.firstName} ${p1.lastName}'.trim();
          if (name.isNotEmpty) p1Name = name;
        } catch (e) {
          dev.log('⚠️ Could not fetch player1: $e');
        }
      }

      if (match.player2Id != null && match.player2Id!.isNotEmpty) {
        try {
          final p2 = await UserController.instance.getUserById(match.player2Id!);
          final name = '${p2.firstName} ${p2.lastName}'.trim();
          if (name.isNotEmpty) p2Name = name;
        } catch (e) {
          dev.log('⚠️ Could not fetch player2: $e');
        }
      }

      // ✅ null-safe event name — fallback to roundName or 'Practice'
      String eventName = match.roundName ?? 'Practice';
      if (match.eventId.isNotEmpty) {
        try {
          final event =
          await EventRepository.instance.fetchSingleItem(match.eventId);
          if (event.name.isNotEmpty) eventName = event.name;
        } catch (e) {
          dev.log('⚠️ Could not fetch event: $e');
        }
      }

      // ✅ null-safe frame stats
      final allFrames = await MatchStatsRepository.instance
          .fetchFramesByMatch(matchId)
          .catchError((_) => <dynamic>[]);

      final currentFrame =
          allFrames.where((f) => f.winnerId == null).firstOrNull;
      final completedFrames =
      allFrames.where((f) => f.winnerId != null).toList();

      final player1FramesWon = completedFrames
          .where((f) => f.winnerId == match.player1Id)
          .length;
      final player2FramesWon = completedFrames
          .where((f) => f.winnerId == match.player2Id)
          .length;

      final p1HighestBreak = allFrames.isEmpty
          ? 0
          : allFrames
          .map((f) => f.player1HighestBreak as int)
          .reduce((a, b) => a > b ? a : b);
      final p2HighestBreak = allFrames.isEmpty
          ? 0
          : allFrames
          .map((f) => f.player2HighestBreak as int)
          .reduce((a, b) => a > b ? a : b);

      final data = {
        'matchId': matchId,
        'matchName': eventName,
        'roundName': match.roundName ?? '',
        'venueName': 'Venue',
        'player1Name': p1Name,
        'player2Name': p2Name,
        'player1Score': currentFrame?.player1Points ?? 0,
        'player2Score': currentFrame?.player2Points ?? 0,
        'player1FramesWon': player1FramesWon,
        'player2FramesWon': player2FramesWon,
        'totalFrames': match.totalFrames,
        'currentFrameNumber': currentFrame?.frameNumber ?? 1,
        'player1CurrentBreak': statsController.getPlayer1Break(matchId),
        'player2CurrentBreak': statsController.getPlayer2Break(matchId),
        'player1HighestBreak': p1HighestBreak,
        'player2HighestBreak': p2HighestBreak,
        'isPlayer1Active':
        statsController.getCurrentPlayer(matchId) == 'player1',
        'isPlayer2Active':
        statsController.getCurrentPlayer(matchId) == 'player2',
      };

      dev.log('✅ Match data built successfully');
      return data;
    } catch (e, stack) {
      dev.log('❌ Error building match data: $e');
      dev.log('❌ Stack: $stack');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // Preview
  // ─────────────────────────────────────────

  Future<void> startPreview() async {
    try {
      final matchData = await buildMatchData();
      await previewController.startPreview(matchData: matchData);
    } catch (e) {
      dev.log('❌ startPreview error: $e');
      rethrow;
    }
  }

  Future<void> stopPreview() async {
    await previewController.stopPreview();
  }

  Future<void> toggleBreakScreen() async {
    if (isBreakActive.value) {
      await StreamingService.hideBreakScreen();
      isBreakActive.value = false;
    } else {
      await StreamingService.showBreakScreen();
      isBreakActive.value = true;
    }
  }

  // ─────────────────────────────────────────
  // Go Live
  // ─────────────────────────────────────────

  Future<void> goLive({required String matchName}) async {
    try {
      dev.log('🎬 Going live...');

      final matchData = await buildMatchData();

      final matchDoc =
      await _db.collection('Matches').doc(matchId).get();
      final matchDataFromDb = matchDoc.data();

      String? streamKey = matchDataFromDb?['streamKey'] as String?;
      String? rtmpUrl = matchDataFromDb?['rtmpUrl'] as String?;
      String? broadcastId = matchDataFromDb?['broadcastId'] as String?;

      // Create broadcast if not exists
      if (streamKey == null ||
          streamKey.isEmpty ||
          rtmpUrl == null ||
          rtmpUrl.isEmpty ||
          broadcastId == null ||
          broadcastId.isEmpty) {
        dev.log('📺 Creating YouTube broadcast...');

        final streamData = await broadcastController.createBroadcast(
          matchId: matchId,
          matchName: matchData['matchName'] as String,
          player1Name: matchData['player1Name'] as String,
          player2Name: matchData['player2Name'] as String,
          venueName: matchData['venueName'] as String,
          eventName: null,
        );

        if (streamData == null) {
          throw Exception('Failed to create broadcast');
        }

        streamKey = streamData['streamKey'];
        rtmpUrl = streamData['rtmpUrl'];
        broadcastId = streamData['broadcastId'];
      }

      await streamController.startStreaming(
        rtmpUrl: rtmpUrl!,
        streamKey: streamKey!,
        matchData: matchData,
      );

      dev.log('✅ Live streaming started');
    } catch (e) {
      dev.log('❌ Error going live: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // Stop Stream
  // ─────────────────────────────────────────

  Future<void> stopStream() async {
    try {
      dev.log('🛑 Stopping stream...');
      await streamController.stopStreaming();
      if (broadcastController.broadcastId.value != null) {
        await broadcastController
            .completeBroadcast(broadcastController.broadcastId.value!);
      }
      dev.log('✅ Stream stopped');
    } catch (e) {
      dev.log('❌ Error stopping stream: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // Scoreboard
  // ─────────────────────────────────────────

  Future<void> updateScoreboard() async {
    try {
      final matchData = await buildMatchData();
      await streamController.updateScoreboard(matchData);
    } catch (e) {
      dev.log('❌ updateScoreboard error: $e');
    }
  }

  // ─────────────────────────────────────────
  // Camera / Audio
  // ─────────────────────────────────────────

  Future<void> toggleAudio() async => audioController.toggleMute();

  Future<void> switchCamera() async => cameraController.switchCamera();

  // Future<void> toggleAutoFocus() async =>
  //     cameraController.toggleAutoFocus();

  void updateQuality({
    required String resolution,
    required int width,
    required int height,
  }) {
    previewController.updateQuality(
      resolution: resolution,
      width: width,
      height: height,
    );
  }
}