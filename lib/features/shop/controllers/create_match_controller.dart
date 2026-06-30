import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../data/services/notifications/notification_service.dart';
import '../../../data/services/youtube/youtube_service.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/match_model.dart';
import '../screens/event_particapnts/event_particapants_screen.dart';
import 'matches_controller.dart';

class CreateMatchController extends GetxController {
  static const String _tag = 'CreateMatchController';

  final String eventId;
  final MatchModel? existingMatch;
  final bool isPractice;

  CreateMatchController({
    required this.eventId,
    this.existingMatch,
    this.isPractice = false,
  });

  final formKey = GlobalKey<FormState>();
  final matchController = Get.find<MatchController>();
  final youtubeService = YouTubeService();

  // Form controllers
  final roundNameController = TextEditingController();
  final player2NameController = TextEditingController(); // for unregistered player 2 in practice

  // Observables
  final totalFrames = Rx<int?>(null); // null = not set, mandatory
  final player1Id = Rx<String?>(null);
  final player2Id = Rx<String?>(null);
  final player1Name = Rx<String?>(null);
  final player2Name = Rx<String?>(null);
  final scheduledTime = DateTime.now().obs;
  final enableLiveStream = false.obs;
  final isLoadingPlayers = false.obs;
  final selectedSportId = Rx<String?>(null);
  final selectedSportName = Rx<String?>(null);

  // Streaming fields
  final streamKey = Rx<String?>(null);
  final rtmpUrl = Rx<String?>(null);
  final broadcastId = Rx<String?>(null);
  final youtubeLink = Rx<String?>(null);

  final userId = FirebaseAuth.instance.currentUser!.uid;

  bool get isEditMode => existingMatch != null;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[$_tag] onInit — isPractice: $isPractice isEditMode: $isEditMode eventId: $eventId');

    if (isPractice) {
      // Auto-fill player 1 from logged in user
      _autoFillPlayer1();
      // Set round name to Practice
      roundNameController.text = 'Practice';
    }

    if (isEditMode) _prefill();
  }

  @override
  void onClose() {
    debugPrint('[$_tag] onClose — disposing controllers');
    roundNameController.dispose();
    player2NameController.dispose();
    super.onClose();
  }

  /// Auto-fill player 1 from logged in user for practice matches
  Future<void> _autoFillPlayer1() async {
    try {
      debugPrint('[$_tag] _autoFillPlayer1 — fetching user: $userId');
      final user = await UserRepository.instance.fetchUserById(userId);
      player1Id.value = userId;
      player1Name.value = user.fullName.isNotEmpty ? user.fullName : user.firstName;
      debugPrint('[$_tag] _autoFillPlayer1 — set: ${player1Name.value}');
    } catch (e) {
      debugPrint('[$_tag] _autoFillPlayer1 — error: $e');
    }
  }

  /// Prefill form fields when editing existing match
  Future<void> _prefill() async {
    final m = existingMatch!;
    debugPrint('[$_tag] _prefill — matchId: ${m.id}');

    roundNameController.text = m.roundName ?? '';
    totalFrames.value = m.totalFrames;
    player1Id.value = m.player1Id;
    player2Id.value = m.player2Id;
    scheduledTime.value = m.scheduledTime;
    enableLiveStream.value = m.liveStreamingEnabled;
    streamKey.value = m.streamKey;
    rtmpUrl.value = m.rtmpUrl;
    broadcastId.value = m.broadcastId;
    youtubeLink.value = m.youtubeLink;
    selectedSportId.value = m.sportId;

    try {
      isLoadingPlayers.value = true;
      if (m.player1Id != null && m.player1Id!.isNotEmpty) {
        final p1 = await UserRepository.instance.fetchUserById(m.player1Id!);
        player1Name.value = p1.fullName.isNotEmpty ? p1.fullName : p1.firstName;
        debugPrint('[$_tag] _prefill — player1: ${player1Name.value}');
      }
      if (m.player2Id != null && m.player2Id!.isNotEmpty) {
        final p2 = await UserRepository.instance.fetchUserById(m.player2Id!);
        player2Name.value = p2.fullName.isNotEmpty ? p2.fullName : p2.firstName;
        debugPrint('[$_tag] _prefill — player2: ${player2Name.value}');
      } else if (m.player2Name != null) {
        // unregistered player 2
        player2Name.value = m.player2Name;
        player2NameController.text = m.player2Name!;
      }
    } catch (e) {
      debugPrint('[$_tag] _prefill — error fetching player names: $e');
    } finally {
      isLoadingPlayers.value = false;
    }
  }

  /// Select player from event participants — used for tournament matches
  Future<void> selectPlayer(BuildContext context, {required bool isPlayer1}) async {
    debugPrint('[$_tag] selectPlayer — isPlayer1: $isPlayer1');
    final result = await Get.to(() => EventParticipantsScreen(
      eventId: eventId,
      selectMode: true,
      singleSelect: true,
      showCreateMatch: true,
    ));

    if (result != null && result['userId'] != null) {
      final uid = result['userId'] as String;
      final name = result['userName'] as String;
      debugPrint('[$_tag] selectPlayer — selected: $uid name: $name');
      if (isPlayer1) {
        player1Id.value = uid;
        player1Name.value = name;
      } else {
        player2Id.value = uid;
        player2Name.value = name;
      }
    } else {
      debugPrint('[$_tag] selectPlayer — no player selected');
    }
  }

  /// Set player 2 from QR scan result (registered CueX user)
  Future<void> setPlayer2FromQR(String scannedUserId) async {
    try {
      debugPrint('[$_tag] setPlayer2FromQR — userId: $scannedUserId');
      isLoadingPlayers.value = true;
      final user = await UserRepository.instance.fetchUserById(scannedUserId);
      if (user.id.isEmpty) {
        TLoaders.errorSnackBar(title: 'Not Found', message: 'Player not found on CueX');
        return;
      }
      player2Id.value = scannedUserId;
      player2Name.value = user.fullName.isNotEmpty ? user.fullName : user.firstName;
      debugPrint('[$_tag] setPlayer2FromQR — set: ${player2Name.value}');
    } catch (e) {
      debugPrint('[$_tag] setPlayer2FromQR — error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: 'Could not fetch player details');
    } finally {
      isLoadingPlayers.value = false;
    }
  }

  /// Set player 2 manually by name (unregistered player)
  void setPlayer2ByName(String name) {
    debugPrint('[$_tag] setPlayer2ByName — name: $name');
    player2Id.value = null; // no userId for unregistered
    player2Name.value = name;
  }

  /// Set selected sport
  void selectSport(String sportId, String sportName) {
    debugPrint('[$_tag] selectSport — sportId: $sportId name: $sportName');
    selectedSportId.value = sportId;
    selectedSportName.value = sportName;
  }

  /// Pick scheduled date and time
  Future<void> selectDateTime(BuildContext context) async {
    debugPrint('[$_tag] selectDateTime — current: ${scheduledTime.value}');
    final date = await showDatePicker(
      context: context,
      initialDate: scheduledTime.value,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(scheduledTime.value),
      );
      if (time != null) {
        scheduledTime.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        debugPrint('[$_tag] selectDateTime — updated: ${scheduledTime.value}');
      }
    }
  }

  /// Validate form before creating/updating match
  bool _validate() {
    if (!formKey.currentState!.validate()) {
      debugPrint('[$_tag] _validate — form validation failed');
      return false;
    }
    if (totalFrames.value == null || totalFrames.value! <= 0) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please enter total frames');
      return false;
    }
    if (player1Id.value == null) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Player 1 is required');
      return false;
    }
    if (player2Id.value == null && (player2Name.value == null || player2Name.value!.isEmpty)) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please add Player 2');
      return false;
    }
    if (player1Id.value != null && player1Id.value == player2Id.value) {
      TLoaders.errorSnackBar(title: 'Invalid', message: 'Player 1 and Player 2 cannot be the same');
      return false;
    }
    if (!isPractice && selectedSportId.value == null) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please select a sport');
      return false;
    }
    return true;
  }

  /// Create new match
  Future<void> createMatch(BuildContext context) async {
    debugPrint('[$_tag] createMatch — started isPractice: $isPractice');
    try {
      if (!_validate()) return;

      TFullScreenLoader.openLoadingDialog('Creating Match...', TImages.docerAnimation);


      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        debugPrint('[$_tag] createMatch — no internet');
        TFullScreenLoader.stopLoading();
        return;
      }

      // ═══════════════════════════════════════════════════
      // PAYMENT CHECK — uncomment when Razorpay is ready
      // ═══════════════════════════════════════════════════
      // if (isPractice) {
      //   debugPrint('[$_tag] createMatch — checking practice match credits');
      //   final hasCredits = await StreamingCreditsController.instance.hasCredits(userId);
      //   if (!hasCredits) {
      //     TFullScreenLoader.stopLoading();
      //     TLoaders.warningSnackBar(
      //       title: 'No Credits',
      //       message: 'Purchase match credits to create a practice match (₹20/match)',
      //     );
      //     // TODO: Open Razorpay payment sheet here
      //     // await RazorpayService.instance.openPayment(amount: 20, userId: userId);
      //     return;
      //   }
      //   await StreamingCreditsController.instance.consumeCredit(userId);
      //   debugPrint('[$_tag] createMatch — credit deducted');
      // }
      // ═══════════════════════════════════════════════════

      String? sKey, rUrl, bId, yLink;

      // Only create YouTube broadcast if live stream enabled
      if (enableLiveStream.value) {
        debugPrint('[$_tag] createMatch — creating YouTube broadcast');
        try {
          final streamData = await youtubeService.createLiveBroadcast(
            userId: userId,
            title: '${player1Name.value} vs ${player2Name.value} | Live on CueX',
            description: 'Watch this live cue sports match on CueX — the ultimate platform for snooker, pool & billiards.\n\nDownload CueX: https://play.google.com/store/apps/details?id=com.cuex_app',
            tags: ['snooker', 'live', player1Name.value ?? '', player2Name.value ?? ''],
          );
          sKey = streamData['stream_key'];
          rUrl = streamData['rtmp_url'];
          bId = streamData['broadcast_id'];
          yLink = streamData['youtube_link'];
          debugPrint('[$_tag] createMatch — broadcast created: $bId');
        } catch (e) {
          debugPrint('[$_tag] createMatch — YouTube error: $e');
          TFullScreenLoader.stopLoading();
          TLoaders.errorSnackBar(title: 'YouTube Error', message: e.toString());
          return;
        }
      }

      final match = MatchModel(
        id: '',
        eventId: isPractice ? '' : eventId,
        player1Id: player1Id.value,
        player2Id: player2Id.value,
        player1Name: isPractice ? player1Name.value : null,
        player2Name: (isPractice && player2Id.value == null) ? player2Name.value : null,
        roundName: isPractice ? 'Practice' : roundNameController.text.trim(),
        totalFrames: totalFrames.value!,
        scheduledTime: scheduledTime.value,
        matchStatus: 'upcoming',
        matchType: isPractice ? 'practice' : 'tournament',
        player1FramesWon: 0,
        player2FramesWon: 0,
        player1CurrentPoints: 0,
        player2CurrentPoints: 0,
        liveStreamingEnabled: enableLiveStream.value,
        isStreaming: false,
        streamKey: sKey ?? '',
        rtmpUrl: rUrl ?? '',
        broadcastId: bId ?? '',
        youtubeLink: yLink ?? '',
        sportId: selectedSportId.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      debugPrint('[$_tag] createMatch — saving to Firestore');
      await matchController.addMatch(match);
      debugPrint('[$_tag] createMatch — match saved successfully');

      // Only notify for tournament matches
      if (!isPractice) {
        await _notifyPlayers(match);
      }

      TFullScreenLoader.stopLoading();

      if (context.mounted) {
        TLoaders.successSnackBar(title: 'Success', message: 'Match created successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop();
      }
    } catch (e, stack) {
      debugPrint('[$_tag] createMatch — error: $e');
      debugPrint('[$_tag] createMatch — stack: $stack');
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Update existing match
  Future<void> updateMatch(BuildContext context) async {
    debugPrint('[$_tag] updateMatch — matchId: ${existingMatch?.id}');
    try {
      if (!_validate()) return;

      TFullScreenLoader.openLoadingDialog('Updating Match...', TImages.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        debugPrint('[$_tag] updateMatch — no internet');
        TFullScreenLoader.stopLoading();
        return;
      }

      // Keep existing stream data
      String? sKey = streamKey.value;
      String? rUrl = rtmpUrl.value;
      String? bId = broadcastId.value;
      String? yLink = youtubeLink.value;

      // Create new broadcast only if live stream enabled but no existing key
      if (enableLiveStream.value && (sKey == null || sKey.isEmpty)) {
        debugPrint('[$_tag] updateMatch — creating new broadcast');
        try {
          final streamData = await youtubeService.createLiveBroadcast(
            userId: userId,
            title: '${player1Name.value} vs ${player2Name.value}',
            description: 'Live snooker match',
            tags: ['snooker', 'live', player1Name.value ?? '', player2Name.value ?? ''],
          );
          sKey = streamData['stream_key'];
          rUrl = streamData['rtmp_url'];
          bId = streamData['broadcast_id'];
          yLink = streamData['youtube_link'];
          debugPrint('[$_tag] updateMatch — broadcast created: $bId');
        } catch (e) {
          debugPrint('[$_tag] updateMatch — YouTube error: $e');
          TFullScreenLoader.stopLoading();
          TLoaders.errorSnackBar(title: 'YouTube Error', message: e.toString());
          return;
        }
      }

      final updated = existingMatch!.copyWith(
        player1Id: player1Id.value,
        player2Id: player2Id.value,
        player1Name: player1Name.value,
        player2Name: player2Name.value,
        roundName: isPractice ? 'Practice' : roundNameController.text.trim(),
        totalFrames: totalFrames.value,
        scheduledTime: scheduledTime.value,
        liveStreamingEnabled: enableLiveStream.value,
        streamKey: sKey ?? '',
        rtmpUrl: rUrl ?? '',
        broadcastId: bId ?? '',
        youtubeLink: yLink ?? '',
        sportId: selectedSportId.value,
        updatedAt: DateTime.now(),
      );

      debugPrint('[$_tag] updateMatch — saving to Firestore');
      await matchController.matchRepository.updateItem(updated);
      debugPrint('[$_tag] updateMatch — updated successfully');

      await matchController.fetchLiveMatches();
      await matchController.fetchUpcomingMatches();

      TFullScreenLoader.stopLoading();

      if (context.mounted) {
        TLoaders.successSnackBar(title: 'Updated', message: 'Match updated successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop();
      }
    } catch (e, stack) {
      debugPrint('[$_tag] updateMatch — error: $e');
      debugPrint('[$_tag] updateMatch — stack: $stack');
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Send notification to players — tournament matches only
  Future<void> _notifyPlayers(MatchModel match) async {
    debugPrint('[$_tag] _notifyPlayers — matchId: ${match.id}');
    try {
      await TNotificationService.instance.sendToTopic(
        topic: 'all_users',
        title: 'Match Scheduled 🎱',
        body: '${player1Name.value} vs ${player2Name.value} — coming soon!',
        data: {'type': 'match_created', 'matchId': match.id},
      );
      debugPrint('[$_tag] _notifyPlayers — sent');
    } catch (e) {
      debugPrint('[$_tag] _notifyPlayers — error (non-fatal): $e');
    }
  }
}