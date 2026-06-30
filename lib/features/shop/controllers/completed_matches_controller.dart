import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/events/event_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/match_model.dart';
import 'matches_controller.dart';

class CompletedMatchesController extends GetxController {

  bool isLoading = false;
  List<MatchModel> matches = [];

  final Map<String, String> eventNames = {};
  final Map<String, String> playerNames = {};

  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  Future<void> loadData() async {
    try {
      isLoading = true;
      update(['loading']);

      final result = await Get.find<MatchController>()
          .matchRepository
          .fetchCompletedMatches();

      await _preloadMaps(result);

      matches = result;

      update(['matches']);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading = false;
      update(['loading']);
    }
  }

  Future<void> _preloadMaps(List<MatchModel> result) async {
    try {

      final events = await Get.find<EventRepository>().fetchAllItems();

      for (final e in events) {
        eventNames[e.id] = e.name;
      }

      final playerIds = <String>{};

      for (final m in result) {
        if (m.player1Id != null) playerIds.add(m.player1Id!);
        if (m.player2Id != null) playerIds.add(m.player2Id!);
      }

      final users =
      await UserController.instance.getMultipleUsers(playerIds.toList());

      for (final u in users) {
        playerNames[u.id] = u.fullName;
      }

    } catch (_) {}
  }

  void search(String value) {
    searchQuery = value;
    update(['matches']);
  }

  List<MatchModel> filteredMatches() {

    if (searchQuery.isEmpty) return matches;

    final q = searchQuery.toLowerCase();

    return matches.where((m) {

      final eventName = eventNames[m.eventId]?.toLowerCase() ?? '';
      final p1 = playerNames[m.player1Id ?? '']?.toLowerCase() ?? '';
      final p2 = playerNames[m.player2Id ?? '']?.toLowerCase() ?? '';

      return eventName.contains(q) || p1.contains(q) || p2.contains(q);

    }).toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}