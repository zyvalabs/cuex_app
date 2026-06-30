import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../../data/services/youtube/youtube_service.dart';

class BroadcastController extends GetxController {
  final YouTubeService _youtubeService = YouTubeService();
  final _db = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  final isCreating = false.obs;
  final isStarting = false.obs;
  final isStopping = false.obs;
  final broadcastId = Rx<String?>(null);
  final streamId = Rx<String?>(null);
  final error = Rx<String?>(null);

  Future<Map<String, String>?> createBroadcast({
    required String matchId,
    required String matchName,
    required String player1Name,
    required String player2Name,
    required String venueName,
    String? eventName,
  }) async {
    try {
      isCreating.value = true;
      error.value = null;

      final title = '$player1Name vs $player2Name - $venueName';
      final description = 'Live cue sports match at $venueName${eventName != null ? " — $eventName" : ""}\n\nWatch live on CueX — the ultimate platform for snooker, pool & billiards.\n\nDownload CueX: https://play.google.com/store/apps/details?id=com.cuex_app';
      final tags = ['snooker', 'live', venueName, player1Name, player2Name];

      final streamData = await _youtubeService.createLiveBroadcast(
        userId: userId,
        title: title,
        description: description,
        tags: tags,
      );

      await _db.collection('Matches').doc(matchId).update({
        'streamKey': streamData['stream_key'],
        'rtmpUrl': streamData['rtmp_url'],
        'broadcastId': streamData['broadcast_id'],
        'youtubeLink': streamData['youtube_link'],
        'streamingPlatform': 'youtube',
      });

      broadcastId.value = streamData['broadcast_id'];
      streamId.value = streamData['broadcast_id'];

      _logEvent('broadcast_created', {'match_id': matchId, 'match_name': matchName});

      return {
        'rtmpUrl': streamData['rtmp_url']!,
        'streamKey': streamData['stream_key']!,
        'broadcastId': streamData['broadcast_id']!,
        'youtubeLink': streamData['youtube_link']!,
      };
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> startBroadcast(String bId) async {
    try {
      isStarting.value = true;
      error.value = null;
      await _youtubeService.startBroadcast(userId, bId);
      _logEvent('broadcast_started', {'broadcast_id': bId});
    } catch (e) {
      error.value = e.toString();
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> completeBroadcast(String bId) async {
    try {
      isStopping.value = true;
      error.value = null;
      await _youtubeService.stopBroadcast(userId, bId);
      _logEvent('broadcast_completed', {'broadcast_id': bId});
    } catch (e) {
      error.value = e.toString();
    } finally {
      isStopping.value = false;
    }
  }

  void _logEvent(String event, Map<String, dynamic> data) {
    print('Analytics: $event $data');
  }
}