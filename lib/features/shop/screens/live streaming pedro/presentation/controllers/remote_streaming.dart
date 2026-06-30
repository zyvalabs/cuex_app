import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

import '../../../../../../data/repositories/events/event_repository.dart';
import '../../../../../../data/repositories/match stats/match_stats_repository.dart';
import '../../../../../../data/repositories/matches/matches_repository.dart';
import '../../../../../personalization/controllers/user_controller.dart';
import '../../../../controllers/match_stat_controller.dart';
import '../controllers/preview_controller.dart';
import '../controllers/stream_controller.dart';
import 'audio_controller.dart';
import 'broadcast_controller.dart';
import 'camera_controller.dart';

class RemoteStreamCoordinator extends GetxController {
  final _db = FirebaseFirestore.instance;
  final matchId = ''.obs;

  void setMatchId(String id) {
    matchId.value = id;
    dev.log('🎯 Match ID set: $id');
  }

  PreviewController get previewController => Get.find<PreviewController>();
  LiveStreamController get streamController => Get.find<LiveStreamController>();
  AudioController get audioController => Get.find<AudioController>();
  CameraController get cameraController => Get.find<CameraController>();
  BroadcastController get broadcastController => Get.find<BroadcastController>();

  Future<Map<String, dynamic>> buildMatchData() async {
    try {
      dev.log('🔨 Building match data for matchId: ${matchId.value}');

      final match = await MatchRepository.instance.fetchSingleItem(matchId.value);
      final player1 = await UserController.instance.getUserById(match.player1Id!);
      final player2 = await UserController.instance.getUserById(match.player2Id!);
      final event = await EventRepository.instance.fetchSingleItem(match.eventId);
      final allFrames = await MatchStatsRepository.instance.fetchFramesByMatch(matchId.value);

      final currentFrame = allFrames.where((f) => f.winnerId == null).firstOrNull;
      final completedFrames = allFrames.where((f) => f.winnerId != null).toList();

      final player1FramesWon = completedFrames.where((f) => f.winnerId == match.player1Id).length;
      final player2FramesWon = completedFrames.where((f) => f.winnerId == match.player2Id).length;

      final p1HighestBreak = allFrames.isEmpty ? 0 : allFrames.map((f) => f.player1HighestBreak).reduce((a, b) => a > b ? a : b);
      final p2HighestBreak = allFrames.isEmpty ? 0 : allFrames.map((f) => f.player2HighestBreak).reduce((a, b) => a > b ? a : b);

      final statsController = Get.find<MatchStatsController>();

      final data = {
        'matchName': event.name,
        'roundName': match.roundName ?? '',
        'venueName': 'Venue',
        'player1Name': '${player1.firstName} ${player1.lastName}',
        'player2Name': '${player2.firstName} ${player2.lastName}',
        'player1Score': currentFrame?.player1Points ?? 0,
        'player2Score': currentFrame?.player2Points ?? 0,
        'player1FramesWon': player1FramesWon,
        'player2FramesWon': player2FramesWon,
        'totalFrames': match.totalFrames,
        'currentFrameNumber': currentFrame?.frameNumber ?? 1,
        'player1CurrentBreak': statsController.getPlayer1Break(matchId.value),
        'player2CurrentBreak': statsController.getPlayer2Break(matchId.value),
        'player1HighestBreak': p1HighestBreak,
        'player2HighestBreak': p2HighestBreak,
        'isPlayer1Active': MatchStatsController.instance.getCurrentPlayer(matchId.value) == 'player1',
        'isPlayer2Active': MatchStatsController.instance.getCurrentPlayer(matchId.value) == 'player2',
      };

      dev.log('✅ Match data built: $data');
      return data;
    } catch (e) {
      dev.log('❌ Error building match data: $e');
      rethrow;
    }
  }

  Future<void> startPreview() async {
    if (matchId.value.isEmpty) {
      await previewController.startPreview(matchData: {});
      return;
    }
    final matchData = await buildMatchData();
    await previewController.startPreview(matchData: matchData);
  }
  Future<void> stopPreview() async {
    await previewController.stopPreview();
  }

  Future<void> goLive({required String matchName}) async {
    try {
      dev.log('🎬 Going live...');
      final matchData = await buildMatchData();
      final matchDoc = await _db.collection('Matches').doc(matchId.value).get();
      final matchDataFromDb = matchDoc.data();

      String? streamKey = matchDataFromDb?['streamKey'] as String?;
      String? rtmpUrl = matchDataFromDb?['rtmpUrl'] as String?;
      String? broadcastId = matchDataFromDb?['broadcastId'] as String?;

      if (streamKey == null || rtmpUrl == null || broadcastId == null) {
        final streamData = await broadcastController.createBroadcast(
          matchId: matchId.value,
          matchName: matchData['matchName'] as String,
          player1Name: matchData['player1Name'] as String,
          player2Name: matchData['player2Name'] as String,
          venueName: matchData['venueName'] as String,
          eventName: null,
        );
        if (streamData == null) throw Exception('Failed to create broadcast');
        streamKey = streamData['streamKey'];
        rtmpUrl = streamData['rtmpUrl'];
        broadcastId = streamData['broadcastId'];
      }

      await streamController.startStreaming(
        rtmpUrl: rtmpUrl!,
        streamKey: streamKey!,
        matchData: matchData,
      );
      await Future.delayed(const Duration(seconds: 5)); // wait for RTMP to connect
      await broadcastController.startBroadcast(broadcastId!);
      await _db.collection('Matches').doc(matchId.value).update({
        'isStreaming': true, // add this
      });
      dev.log('✅ Live streaming started');
    } catch (e) {
      dev.log('❌ Error going live: $e');
      rethrow;
    }
  }

  Future<void> stopStream() async {
    try {
      await streamController.stopStreaming();
      if (broadcastController.broadcastId.value != null) {
        await broadcastController.completeBroadcast(broadcastController.broadcastId.value!);
      }
      await _db.collection('Matches').doc(matchId.value).update({
        'isStreaming': false,
      });
      dev.log('✅ Stream stopped');
    } catch (e) {
      dev.log('❌ Error stopping stream: $e');
      rethrow;
    }
  }

  Future<void> updateScoreboard() async {
    final matchData = await buildMatchData();
    await streamController.updateScoreboard(matchData);
  }

  Future<void> toggleAudio() async => audioController.toggleMute();
  Future<void> switchCamera() async => cameraController.switchCamera();
  // Future<void> toggleAutoFocus() async => cameraController.toggleAutoFocus();

  void updateQuality({required String resolution, required int width, required int height}) {
    previewController.updateQuality(resolution: resolution, width: width, height: height);
  }
}