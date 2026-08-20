import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../core/model/sports_model.dart';
import '../core/model/match_model.dart';

import '../data/services/youtube/youtube_service.dart';
import '../repositories/match_repository.dart';

/// Controller for the entire "New Match" creation flow (all 4 steps).
/// Holds every value collected across the wizard and orchestrates the
/// final save — including YouTube broadcast creation, thumbnail upload,
/// and writing the finished MatchModel to Firestore.
class MatchCreationController extends GetxController {
  final YouTubeService _youtubeService = YouTubeService();
  final MatchRepository _matchRepository = MatchRepository();
  final ImagePicker _imagePicker = ImagePicker();

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // ==========================================================
  // STEP 1: Sport selection
  // ==========================================================

  final Rx<SportsModel> selectedSport = kSports.first.obs;

  void selectSport(SportsModel sport) => selectedSport.value = sport;
  bool isSelected(SportsModel sport) => selectedSport.value.name == sport.name;

  // ---------------- Event linkage (null for standalone practice matches) ----------------
  final RxnString eventId = RxnString();
  final TextEditingController roundNameController = TextEditingController();

  /// Called when starting a match from within an EventDetailsScreen's
  /// "Add Match" button — locks the sport (inherited from the event) and
  /// tags this match with the event's id, so the wizard can skip sport
  /// selection and show the Round Name field instead.
  void presetFromEvent({required String eventIdValue, required SportsModel sport}) {
    eventId.value = eventIdValue;
    selectedSport.value = sport;
  }

  bool get isLinkedToEvent => eventId.value != null;

  // ==========================================================
  // STEP 2: Match setup — type, format, players
  // ==========================================================

  final RxnString selectedMatchType = RxnString('Singles'); // default pre-selected
  final RxInt bestOfFrames = 3.obs; // also reused as race-to-points value for Billiards
  final RxnString selectedFormatValue = RxnString(); // reds count / 8-ball-9-ball
  final RxString mode = 'Practice'.obs; // silently defaults — no selector shown yet

  /// Player name controllers — fixed pool of 4, only first N are shown/used
  /// depending on match type. Kept as TextEditingControllers (not plain
  /// RxList<String>) so we can pre-fill/edit them later when reopening a match.
  final List<TextEditingController> playerControllers = List.generate(
    4,
        (_) => TextEditingController(),
  );

  /// Bumped every time a player field changes — lets Obx() widgets watching
  /// isMatchSetupValid react, since raw TextEditingController text isn't
  /// reactive by itself.
  final RxInt _playerFieldTrigger = 0.obs;
  void onPlayerFieldChanged() => _playerFieldTrigger.value++;

  /// How many player fields should be shown, based on selected match type.
  int get playerFieldCount {
    switch (selectedMatchType.value) {
      case 'Doubles':
        return 4;
      case 'Singles':
        return 2;
      case 'Solo':
        return 1;
      default:
        return 0;
    }
  }

  /// Does this sport need a separate format selector (chips)?
  /// Heyball/Billiards only use the frames/points stepper — no chips needed.
  bool get needsFormatSelector {
    final sportName = selectedSport.value.name;
    return sportName == 'Snooker' || sportName == 'Pool';
  }

  /// Should the Best of Frames stepper show? Hidden for Billiards, which
  /// repurposes the same stepper as "Race to Points" instead.
  bool get showsFramesStepper => selectedSport.value.name != 'Billiards';

  /// Validates Step 2 as a whole — Next button on MatchSetupScreen uses this.
  bool get isMatchSetupValid {
    _playerFieldTrigger.value; // register reactivity
    if (selectedMatchType.value == null) return false;
    if (needsFormatSelector && selectedFormatValue.value == null) return false;
    if (playerFieldCount == 0) return false;
    for (int i = 0; i < playerFieldCount; i++) {
      if (playerControllers[i].text.trim().isEmpty) return false;
    }
    return true;
  }

  // ==========================================================
  // STEP 3: Streaming platform choice
  // ==========================================================

  final RxnString streamPlatform = RxnString(); // 'YouTube' | 'RTMP'

  void selectStreamPlatform(String platform) => streamPlatform.value = platform;

  // ==========================================================
  // STEP 4a: YouTube-specific setup
  // ==========================================================

  final RxBool isYoutubeConnected = false.obs;
  final RxnString youtubeChannelName = RxnString();
  final RxnString youtubeChannelImageUrl = RxnString();

  final RxString youtubeTitle = ''.obs;
  final RxString youtubeDescription = ''.obs;
  final RxnString youtubeThumbnailUrl = RxnString(); // final uploaded URL, used in the API call
  final RxBool isUploadingThumbnail = false.obs;
  final RxString youtubeVisibility = 'Public'.obs; // Public default, per earlier decision

  final RxBool isScheduled = false.obs; // false = Start Now (default)
  final Rxn<DateTime> youtubeScheduledStartTime = Rxn<DateTime>();

  /// Auto-fills title/description from match data collected in Step 2.
  /// Called once when YoutubeSetupScreen loads — user can still edit freely after.
  void autoFillYoutubeMetadata() {
    final sport = selectedSport.value.name;
    final players = playerControllers
        .take(playerFieldCount)
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    final matchup = players.length >= 2 ? '${players[0]} vs ${players[1]}' : players.join(', ');
    final dateStr = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    youtubeTitle.value = '$matchup — $sport — $dateStr';
    youtubeDescription.value =
    'Live $sport match — ${selectedMatchType.value}. Best of ${bestOfFrames.value}. Streamed via CueX.';
  }

  /// Calls YouTubeService to sign in and fetch channel info.
  /// Throws whatever YouTubeService throws — screen should catch and show it.
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

  /// Checks Firestore for an already-connected YouTube account —
  /// call this once when the screen loads, so returning users don't
  /// have to log in again every time.
  Future<void> loadExistingYoutubeConnection() async {
    final connected = await _youtubeService.isConnected(_userId);
    if (connected) {
      final info = await _youtubeService.getChannelInfo(_userId);
      youtubeChannelName.value = info['name'];
      youtubeChannelImageUrl.value = info['image'];
      isYoutubeConnected.value = true;
      autoFillYoutubeMetadata(); // fix: was missing here — only ran on fresh login before
    }
  }

  /// Opens the image picker, then uploads the picked image to Firebase
  /// Storage under a per-user thumbnails folder, and stores the resulting
  /// download URL in youtubeThumbnailUrl.
  Future<void> pickAndUploadThumbnail() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // compress a bit — thumbnails don't need full resolution
    );
    if (picked == null) return; // user cancelled

    isUploadingThumbnail.value = true;
    try {
      final file = File(picked.path);
      final fileName = 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref('thumbnails/$_userId/$fileName');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      youtubeThumbnailUrl.value = downloadUrl;
    } finally {
      isUploadingThumbnail.value = false;
    }
  }

  void setYoutubeVisibility(String visibility) => youtubeVisibility.value = visibility;

  void setScheduleMode(bool scheduled) => isScheduled.value = scheduled;

  void setScheduledDateTime(DateTime dateTime) => youtubeScheduledStartTime.value = dateTime;

  // ==========================================================
  // STEP 4b: RTMP-specific setup
  // ==========================================================

  final RxnString rtmpUrl = RxnString();
  final RxnString streamKey = RxnString();

  /// Set after a successful YouTube broadcast creation — used by
  /// MatchDetailsScreen to show the shareable watch link.
  final RxnString createdYoutubeBroadcastId = RxnString();

  void setRtmpUrl(String value) => rtmpUrl.value = value;
  void setStreamKey(String value) => streamKey.value = value;

  bool get isRtmpSetupValid =>
      (rtmpUrl.value?.trim().isNotEmpty ?? false) && (streamKey.value?.trim().isNotEmpty ?? false);

  // ==========================================================
  // FINAL SAVE — assembles everything and writes to Firestore
  // ==========================================================

  final RxBool isSaving = false.obs;
  final RxnString saveError = RxnString();

  /// Builds the final MatchModel from every value collected across all steps.
  MatchModel _buildMatchModel({String? youtubeBroadcastId, String? resolvedRtmpUrl, String? resolvedStreamKey}) {
    return MatchModel(
      sport: selectedSport.value.name,
      matchType: selectedMatchType.value ?? '',
      format: selectedFormatValue.value ?? '',
      bestOfFrames: bestOfFrames.value,
      mode: mode.value,
      playerNames: playerControllers.take(playerFieldCount).map((c) => c.text.trim()).toList(),
      streamPlatform: streamPlatform.value ?? '',
      youtubeTitle: streamPlatform.value == 'YouTube' ? youtubeTitle.value : null,
      youtubeDescription: streamPlatform.value == 'YouTube' ? youtubeDescription.value : null,
      youtubeThumbnailUrl: streamPlatform.value == 'YouTube' ? youtubeThumbnailUrl.value : null,
      youtubeVisibility: streamPlatform.value == 'YouTube' ? youtubeVisibility.value : null,
      youtubeScheduledStartTime: streamPlatform.value == 'YouTube' && isScheduled.value
          ? youtubeScheduledStartTime.value
          : null,
      youtubeBroadcastId: youtubeBroadcastId,
      rtmpUrl: resolvedRtmpUrl,
      streamKey: resolvedStreamKey,
      createdBy: _userId,
      createdAt: DateTime.now(),
      eventId: eventId.value,
      roundName: roundNameController.text.trim().isNotEmpty ? roundNameController.text.trim() : null,
    );
  }

  /// Main entry point — called when the user taps "Go Live".
  /// Returns the new match's Firestore ID on success, or null on failure
  /// (check saveError for the reason).
  Future<String?> createMatch() async {
    isSaving.value = true;
    saveError.value = null;

    // DEBUG: trace controller-level call
    // ignore: avoid_print
    print('🔵 [MatchCreationController] createMatch() started — platform=${streamPlatform.value}');

    try {
      String? broadcastId;
      String? resolvedRtmpUrl = rtmpUrl.value;
      String? resolvedStreamKey = streamKey.value;

      if (streamPlatform.value == 'YouTube') {
        // This call is also where we genuinely discover verification/quota
        // issues — YouTubeService handles catching and persisting those.
        // ignore: avoid_print
        print('🔵 [MatchCreationController] calling YouTubeService.createLiveBroadcast()...');

        final result = await _youtubeService.createLiveBroadcast(
          userId: _userId,
          title: youtubeTitle.value,
          description: youtubeDescription.value,
          tags: const [],
          privacyStatus: youtubeVisibility.value.toLowerCase(),
          scheduledStartTime: isScheduled.value ? youtubeScheduledStartTime.value : null,
        );

        // ignore: avoid_print
        print('🔵 [MatchCreationController] createLiveBroadcast() result: $result');

        broadcastId = result['broadcast_id'];
        resolvedRtmpUrl = result['rtmp_url'];
        resolvedStreamKey = result['stream_key'];

        createdYoutubeBroadcastId.value = broadcastId; // save for MatchDetailsScreen to display
      }

      final match = _buildMatchModel(
        youtubeBroadcastId: broadcastId,
        resolvedRtmpUrl: resolvedRtmpUrl,
        resolvedStreamKey: resolvedStreamKey,
      );

      // ignore: avoid_print
      print('🔵 [MatchCreationController] writing to Firestore: ${match.toJson()}');

      final matchId = await _matchRepository.createMatch(match);

      // ignore: avoid_print
      print('🟢 [MatchCreationController] Firestore write succeeded — matchId=$matchId');

      isSaving.value = false;
      return matchId;
    } catch (e, stackTrace) {
      // Catches YouTubeQuotaException, LiveStreamingNotEnabledException,
      // YouTubeAuthException, or any Firestore write failure.
      // ignore: avoid_print
      print('🔴 [MatchCreationController] createMatch() FAILED: $e');
      // ignore: avoid_print
      print('🔴 stackTrace: $stackTrace');

      saveError.value = e.toString();
      isSaving.value = false;
      return null;
    }
  }

  @override
  void onClose() {
    for (final c in playerControllers) {
      c.dispose();
    }
    roundNameController.dispose();
    super.onClose();
  }
}