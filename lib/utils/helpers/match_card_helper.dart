import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/events/event_repository.dart';
import '../../data/repositories/user/user_repository.dart';
import '../../features/personalization/controllers/user_controller.dart';
import '../../features/personalization/models/user_model.dart';
import '../../features/shop/models/match_model.dart';

class MatchDataHelper {
  // ✅ static cache — persists across widget rebuilds
  static final Map<String, Map<String, dynamic>> _cache = {};

  // ─────────────────────────────────────────
  // Formatters
  // ─────────────────────────────────────────

  static String formatTime(DateTime time) =>
      DateFormat('h:mm a').format(time);

  static String formatDate(DateTime time) =>
      DateFormat('MMM dd').format(time);

  // ─────────────────────────────────────────
  // Status helpers
  // ─────────────────────────────────────────

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.redAccent;
      case 'upcoming':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  static String getStatus(String status) => status.toUpperCase();

  static String getInitials(String name) =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  // ─────────────────────────────────────────
  // Get match data — cached
  // ─────────────────────────────────────────

  static Future<Map<String, dynamic>> getMatchData(MatchModel match) async {
    // ✅ return from cache instantly
    if (_cache.containsKey(match.id)) {
      return _cache[match.id]!;
    }

    try {
      final userController = UserController.instance;

      // Fetch event
      String eventName = '';
      if (match.eventId.isNotEmpty) {
        try {
          final event = await EventRepository.instance
              .fetchSingleItem(match.eventId);
          eventName = event.name;
        } catch (_) {}
      }

      // Fetch player 1
      UserModel player1 = UserModel.empty();
      if (match.player1Id != null && match.player1Id!.isNotEmpty) {
        try {
          player1 = await userController.getUserById(match.player1Id!);
        } catch (_) {}
      }

      // Fetch player 2
      UserModel player2 = UserModel.empty();
      if (match.player2Id != null && match.player2Id!.isNotEmpty) {
        try {
          player2 = await userController.getUserById(match.player2Id!);
        } catch (_) {}
      }

      final data = <String, dynamic>{
        'eventName': eventName,
        'player1Name': player1.firstName.isNotEmpty
            ? player1.firstName
            : match.player1Name ?? 'Player 1',
        'player1Image': player1.profilePicture,
        'player1Initials': getInitials(
          player1.firstName.isNotEmpty
              ? player1.firstName
              : match.player1Name ?? 'P',
        ),
        'player2Name': player2.firstName.isNotEmpty
            ? player2.firstName
            : match.player2Name ?? 'Player 2',
        'player2Image': player2.profilePicture,
        'player2Initials': getInitials(
          player2.firstName.isNotEmpty
              ? player2.firstName
              : match.player2Name ?? 'P',
        ),
        'roundName': match.roundName ?? '',
      };

      // ✅ save to cache
      _cache[match.id] = data;
      return data;
    } catch (e) {
      debugPrint('🔴 getMatchData error: $e');

      // ✅ cache fallback — no repeated failed calls
      final fallback = <String, dynamic>{
        'eventName': '',
        'player1Name': match.player1Name ?? 'Player 1',
        'player1Image': '',
        'player1Initials': getInitials(match.player1Name ?? 'P'),
        'player2Name': match.player2Name ?? 'Player 2',
        'player2Image': '',
        'player2Initials': getInitials(match.player2Name ?? 'P'),
        'roundName': match.roundName ?? '',
      };

      _cache[match.id] = fallback;
      return fallback;
    }
  }

  // ─────────────────────────────────────────
  // Get match details (for detail screen)
  // ─────────────────────────────────────────

  static Future<Map<String, dynamic>> getMatchDetails(MatchModel match) async {
    try {
      // ✅ add these two lines first
      String p1Name = match.player1Name ?? 'Player 1';
      String p2Name = match.player2Name ?? 'Player 2';

      final event = match.eventId.isNotEmpty
          ? await EventRepository.instance.fetchSingleItem(match.eventId)
          : null;

      if (match.player1Id != null && match.player1Id!.isNotEmpty) {
        try {
          final p1 = await UserRepository.instance.fetchUserById(match.player1Id!);
          if (p1.firstName.isNotEmpty) p1Name = p1.firstName; // ✅ only override if found
        } catch (_) {}
      }

      if (match.player2Id != null && match.player2Id!.isNotEmpty) {
        try {
          final p2 = await UserRepository.instance.fetchUserById(match.player2Id!);
          if (p2.firstName.isNotEmpty) p2Name = p2.firstName; // ✅ only override if found
        } catch (_) {}
      }

      return {
        'tournamentName': event?.name ?? 'Practice',
        'roundName': match.roundName ?? 'Round',
        'player1Name': p1Name,
        'player1Initials': getInitials(p1Name),
        'player2Name': p2Name,
        'player2Initials': getInitials(p2Name),
      };
    } catch (e) {
      debugPrint('🔴 getMatchDetails error: $e');
      return {};
    }
  }

  // ─────────────────────────────────────────
  // Cache management
  // ─────────────────────────────────────────

  /// Call when matches list refreshes
  static void clearCache() {
    _cache.clear();
    debugPrint('🧹 MatchDataHelper cache cleared');
  }

  /// Remove single match from cache
  static void removeFromCache(String matchId) {
    _cache.remove(matchId);
  }

  /// Check if match is cached
  static bool isCached(String matchId) => _cache.containsKey(matchId);
}