import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuex_app/features/shop/controllers/streaming_credit_controller.dart';
import 'package:get/get.dart';
import '../../../data/repositories/matches/matches_repository.dart';
import '../../../data/repositories/venue/venue_repository.dart';

import '../../../data/services/notifications/notification_service.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/match_model.dart';
import '../models/venue_model.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/popups/loaders.dart';
import '../screens/live streaming pedro/presentation/controllers/streaming_coordinator.dart';

class MatchController extends GetxController {
  static MatchController get instance => Get.find();

  final isLoading = false.obs;
  final matchRepository = Get.put(MatchRepository());

  RxList<MatchModel> allMatches = <MatchModel>[].obs;
  RxList<MatchModel> liveMatches = <MatchModel>[].obs;
  RxList<MatchModel> upcomingMatches = <MatchModel>[].obs;
  RxList<MatchModel> completedMatches = <MatchModel>[].obs;
  RxList<MatchModel> featuredMatches = <MatchModel>[].obs;
  Rx<MatchModel?> currentMatch = Rx<MatchModel?>(null);
  final venueMatches = <MatchModel>[].obs;
  Rx<VenueModel?> partnerVenue = Rx<VenueModel?>(null);
  StreamSubscription? _matchSubscription;

  @override
  void onInit() {
    _loadPartnerVenueIfNeeded();
    fetchLiveMatches();
    fetchFeaturedMatches();
    super.onInit();
  }

  @override
  void onClose() {
    _matchSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadPartnerVenueIfNeeded() async {
    final role = UserController.instance.user.value.role;
    if (role == AppRole.partner) {
      final user = UserController.instance.user.value;
      partnerVenue.value = await Get.find<VenueRepository>().fetchPartnerVenue(user.id);
    }
  }

  /// Fetches all venue matches once and splits by status — avoids 3 separate Firestore calls for partner
  Future<void> _fetchAndSplitVenueMatches() async {
    final all = await matchRepository.fetchMatchesByVenue(partnerVenue.value!.id);
    liveMatches.assignAll(all.where((m) => m.matchStatus == 'live').toList());
    upcomingMatches.assignAll(all.where((m) => m.matchStatus == 'upcoming').toList());
    completedMatches.assignAll(all.where((m) => m.matchStatus == 'completed').toList());
  }

  Future<void> fetchAllMatches() async {
    try {
      isLoading.value = true;
      allMatches.assignAll(await matchRepository.fetchAllItems());
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }Future<void> fetchLiveMatches({String? matchType}) async {
    try {
      isLoading.value = true;
      liveMatches.assignAll(
        await matchRepository.fetchLiveMatches(matchType: matchType),
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUpcomingMatches({String? matchType}) async {
    try {
      isLoading.value = true;
      final role = UserController.instance.user.value.role;
      if (role == AppRole.partner && partnerVenue.value != null) {
        await _fetchAndSplitVenueMatches();
      } else {
        upcomingMatches.assignAll(
          await matchRepository.fetchUpcomingMatches(matchType: matchType),
        );
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompletedMatches({String? matchType}) async {
    try {
      isLoading.value = true;
      completedMatches.assignAll(
        await matchRepository.fetchCompletedMatches(matchType: matchType),
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVenueMatches(String venueId) async {
    venueMatches.assignAll(await matchRepository.fetchMatchesByVenue(venueId));
  }

  List<MatchModel> get liveVenueMatches => venueMatches.where((m) => m.matchStatus == 'live').toList();
  List<MatchModel> get upcomingVenueMatches => venueMatches.where((m) => m.matchStatus == 'upcoming').toList();
  List<MatchModel> get completedVenueMatches => venueMatches.where((m) => m.matchStatus == 'completed').toList();

  Future<void> addMatch(MatchModel match) async {
    try {
      isLoading.value = true;

      // Check and deduct credit when match is created
      final creditsController = Get.isRegistered<StreamingCreditsController>()
          ? Get.find<StreamingCreditsController>()
          : Get.put(StreamingCreditsController());

      final venueId = partnerVenue.value?.id ?? '';
      if (venueId.isNotEmpty) {
        final hasCredits = await creditsController.consumeCredit(venueId);
        if (!hasCredits) {
          isLoading.value = false;
          return; // block match creation if no credits
        }
      }

      await MatchRepository.instance.addItem(match);
      await fetchAllMatches();
      TLoaders.successSnackBar(title: 'Success', message: 'Match created');
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMatchesByEvent(String eventId) async {
    try {
      isLoading.value = true;
      allMatches.assignAll(await matchRepository.fetchMatchesByEvent(eventId));
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMatchesByVenue(String venueId) async {
    try {
      isLoading.value = true;
      allMatches.assignAll(await matchRepository.fetchMatchesByVenue(venueId));
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMatchesByPlayer(String playerId) async {
    try {
      isLoading.value = true;
      allMatches.assignAll(await matchRepository.fetchMatchesByPlayer(playerId));
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMatchesByStatus(String status) async {
    try {
      isLoading.value = true;
      allMatches.assignAll(await matchRepository.fetchMatchesByStatus(status));
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<MatchModel?> getMatch(String matchId) async {
    try {
      return await matchRepository.fetchSingleItem(matchId);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<void> updateMatchStatus(String matchId, String status) async {
    try {
      await matchRepository.updateSingleField(matchId, {'matchStatus': status});
      TLoaders.successSnackBar(title: 'Success', message: 'Match status updated');
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> startMatch(String matchId) async {
    try {
      await matchRepository.updateSingleField(matchId, {
        'matchStatus': 'live',
        'startedAt': DateTime.now(),
        'isStreaming': true,
      });
      await fetchLiveMatches();

      final match = await matchRepository.fetchSingleItem(matchId);
      final player1 = await UserController.instance.getUserById(match.player1Id!);
      final player2 = await UserController.instance.getUserById(match.player2Id!);

      await TNotificationService.instance.sendToTopic(
        topic: 'all_users',
        title: 'Match Started 🎱',
        body: '${player1.firstName} vs ${player2.firstName} is now live!',
        data: {'type': 'match_started', 'matchId': matchId},
      );

      TLoaders.successSnackBar(title: 'Success', message: 'Match started');
      if (!Get.isRegistered<StreamingCoordinator>(tag: matchId)) {
        Get.put(StreamingCoordinator(matchId: matchId), tag: matchId);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchFeaturedMatches() async {
    try {
      isLoading.value = true;
      featuredMatches.assignAll(await matchRepository.fetchFeaturedMatches());
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeMatch(String matchId, String winnerId) async {
    try {
      await matchRepository.updateSingleField(matchId, {
        'matchStatus': 'completed',
        'completedAt': DateTime.now(),
        'winnerId': winnerId,
        'isStreaming': false,
      });

      final winner = await UserController.instance.getUserById(winnerId);

      await TNotificationService.instance.sendToTopic(
        topic: 'all_users',
        title: 'Match Over 🏆',
        body: '${winner.firstName} wins the match!',
        data: {'type': 'match_ended', 'matchId': matchId},
      );

      await fetchCompletedMatches();
      TLoaders.successSnackBar(title: 'Success', message: 'Match completed');
      if (Get.isRegistered<StreamingCoordinator>(tag: matchId)) {
        Get.delete<StreamingCoordinator>(tag: matchId);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<String> _getPlayerToken(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      return doc.data()?['fcmToken'] ?? '';
    } catch (e) {
      return '';
    }
  }

  void watchMatch(String matchId) {
    _matchSubscription?.cancel();
    _matchSubscription = matchRepository.watchMatch(matchId).listen(
          (match) {
        currentMatch.value = match;
      },
      onError: (e) => _handleError(e),
    );
  }

  void stopWatchingMatch() => _matchSubscription?.cancel();

  void _handleError(dynamic e) =>
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
}