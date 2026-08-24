import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../data/services/youtube/youtube_service.dart';

import 'match_setup_controller.dart';

/// Holds everything from the YouTube setup step — connection state,
/// metadata (title/description/thumbnail), visibility, and schedule.
class YoutubeSetupController extends GetxController {
  final YouTubeService _youtubeService = YouTubeService();
  final ImagePicker _imagePicker = ImagePicker();

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  final RxBool isYoutubeConnected = false.obs;
  final RxnString youtubeChannelName = RxnString();
  final RxnString youtubeChannelImageUrl = RxnString();

  final RxString youtubeTitle = ''.obs;
  final RxString youtubeDescription = ''.obs;
  final RxnString youtubeThumbnailUrl = RxnString();
  final RxBool isUploadingThumbnail = false.obs;
  final RxString youtubeVisibility = 'Public'.obs;

  final RxBool isScheduled = false.obs;
  final Rxn<DateTime> youtubeScheduledStartTime = Rxn<DateTime>();

  final RxnString createdYoutubeBroadcastId = RxnString();

  /// Auto-fills title/description using data from MatchSetupController.
  void autoFillYoutubeMetadata() {
    final matchSetup = Get.find<MatchSetupController>();
    final sport = matchSetup.selectedSport.value.name;
    final players = matchSetup.playerControllers
        .take(matchSetup.playerFieldCount)
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    final matchup = players.length >= 2 ? '${players[0]} vs ${players[1]}' : players.join(', ');
    final dateStr = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    youtubeTitle.value = '$matchup — $sport — $dateStr';
    youtubeDescription.value =
    'Live $sport match — ${matchSetup.selectedMatchType.value}. Best of ${matchSetup.bestOfFrames.value}. Streamed via CueX.';
  }

  Future<void> connectYoutube() async {
    await _youtubeService.connectYouTube(_userId);
    final info = await _youtubeService.getChannelInfo(_userId);
    youtubeChannelName.value = info['name'];
    youtubeChannelImageUrl.value = info['image'];
    isYoutubeConnected.value = true;
  }

  Future<void> disconnectYoutube() async {
    await _youtubeService.disconnect(_userId);
    isYoutubeConnected.value = false;
    youtubeChannelName.value = null;
    youtubeChannelImageUrl.value = null;
  }

  Future<void> loadExistingYoutubeConnection() async {
    final connected = await _youtubeService.isConnected(_userId);
    if (connected) {
      final info = await _youtubeService.getChannelInfo(_userId);
      youtubeChannelName.value = info['name'];
      youtubeChannelImageUrl.value = info['image'];
      isYoutubeConnected.value = true;
      autoFillYoutubeMetadata();
    }
  }

  Future<void> pickAndUploadThumbnail() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    isUploadingThumbnail.value = true;
    try {
      final file = File(picked.path);
      final fileName = 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref('thumbnails/$_userId/$fileName');
      await ref.putFile(file);
      youtubeThumbnailUrl.value = await ref.getDownloadURL();
    } finally {
      isUploadingThumbnail.value = false;
    }
  }

  void setYoutubeVisibility(String visibility) => youtubeVisibility.value = visibility;
  void setScheduleMode(bool scheduled) => isScheduled.value = scheduled;
  void setScheduledDateTime(DateTime dateTime) => youtubeScheduledStartTime.value = dateTime;

  /// Calls the actual YouTube API to create the live broadcast. Returns
  /// the raw result map (broadcast_id, stream_key, rtmp_url) for
  /// MatchCreationController to use when assembling the final MatchModel.
  Future<Map<String, String>> createLiveBroadcast() async {
    final result = await _youtubeService.createLiveBroadcast(
      userId: _userId,
      title: youtubeTitle.value,
      description: youtubeDescription.value,
      tags: const [],
      privacyStatus: youtubeVisibility.value.toLowerCase(),
      scheduledStartTime: isScheduled.value ? youtubeScheduledStartTime.value : null,
    );
    createdYoutubeBroadcastId.value = result['broadcast_id'];
    return result;
  }
}