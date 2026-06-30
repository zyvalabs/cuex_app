import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../data/repositories/events/event_repository.dart';
import '../../../data/repositories/matches/matches_repository.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/match_model.dart';
import '../models/match_stats_model.dart';

class HighestBreaksController extends GetxController {
  static HighestBreaksController get instance => Get.find();

  final _storage = GetStorage();
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://cuex-ab44c-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  // ── State ──────────────────────────────────────────────
  final RxList<HighestBreakModel> topBreaks = <HighestBreakModel>[].obs;
  final RxList<HighestBreakModel> eventBreaks = <HighestBreakModel>[].obs;
  final RxList<HighestBreakModel> practiceBreaks = <HighestBreakModel>[].obs;
  final isFetching = false.obs;

  static const _ttlMinutes = 30;
  static const _cacheKeyAll = 'topBreaks';
  static const _cacheKeyEvent = 'eventBreaks';
  static const _cacheKeyPractice = 'practiceBreaks';
  static const _cacheKeyTimestamp = 'breaksLastFetch';

  late final MatchRepository _matchRepo;

  @override
  void onInit() {
    super.onInit();
    _matchRepo = Get.isRegistered<MatchRepository>()
        ? Get.find<MatchRepository>()
        : Get.put(MatchRepository());

    // 1. Show cached data instantly
    _loadFromCache();

    // 2. Fetch fresh if stale, then start listener
    _initData();
  }

  // ── Init: TTL check → fetch or skip → start listener ──
  Future<void> _initData() async {
    if (_isStale()) {
      await fetchTopBreaks();
    }
    _startListener();
  }

  // ── TTL check ──────────────────────────────────────────
  bool _isStale() {
    final lastFetch = _storage.read(_cacheKeyTimestamp);
    if (lastFetch == null) return true;
    final diff = DateTime.now().difference(DateTime.parse(lastFetch)).inMinutes;
    return diff >= _ttlMinutes;
  }

  // ── RTDB real-time listener ────────────────────────────
  // Fires automatically when match_stats changes (live scoring)
  void _startListener() {
    _db.child('match_stats').onValue.listen((event) async {
      if (!event.snapshot.exists || event.snapshot.value == null) return;
      await _processSnapshot(event.snapshot.value);
    }, onError: (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'RTDB listener error');
    });
  }

  // ── Manual refresh (pull to refresh etc) ──────────────
  Future<void> fetchTopBreaks() async {
    try {
      isFetching.value = true;
      final snapshot = await _db.child('match_stats').get();
      if (!snapshot.exists || snapshot.value == null) return;
      await _processSnapshot(snapshot.value);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'fetchTopBreaks error');
    } finally {
      isFetching.value = false;
    }
  }

  // ── Core processing ────────────────────────────────────
  Future<void> _processSnapshot(dynamic value) async {
    try {
      if (value is! Map) return;
      final data = _safeMap(value);

      // ── Collect all playerIds and frame breaks first ──
      final List<_RawBreak> rawBreaks = [];
      final Set<String> playerIds = {};

      for (final matchEntry in data.entries) {
        final matchId = matchEntry.key;
        if (matchEntry.value == null || matchEntry.value is! Map) continue;

        final matchData = _safeMap(matchEntry.value);

        MatchModel? match;
        try {
          match = await _matchRepo.fetchSingleItem(matchId);
        } catch (_) {
          continue;
        }

// ✅ skip testing events
        if (match.eventId.isNotEmpty) {
          try {
            final event = await EventRepository.instance.fetchSingleItem(match.eventId);
            if (event.isTesting) continue;
          } catch (_) {}
        }
// ✅ add here
        if (match.isTesting == true) continue;
        final isPractice = match.matchType == 'practice';

        for (final frameEntry in matchData.entries) {
          if (!frameEntry.key.startsWith('frame_')) continue;
          if (frameEntry.value == null || frameEntry.value is! Map) continue;

          final frameNumber = int.tryParse(
            frameEntry.key.replaceFirst('frame_', ''),
          ) ??
              0;

          MatchStatsModel frame;
          try {
            frame = MatchStatsModel.fromRealtimeDB(
              _safeMap(frameEntry.value),
              frameNumber,
              matchId,
            );
          } catch (_) {
            continue;
          }

          if (frame.player1HighestBreak > 0) {
            rawBreaks.add(_RawBreak(
              playerId: match.player1Id,
              fallbackName: match.player1Name ?? 'Player 1',
              score: frame.player1HighestBreak,
              isPractice: isPractice,
            ));
            if (match.player1Id != null && match.player1Id!.isNotEmpty) {
              playerIds.add(match.player1Id!);
            }
          }

          if (frame.player2HighestBreak > 0) {
            rawBreaks.add(_RawBreak(
              playerId: match.player2Id,
              fallbackName: match.player2Name ?? 'Player 2',
              score: frame.player2HighestBreak,
              isPractice: isPractice,
            ));
            if (match.player2Id != null && match.player2Id!.isNotEmpty) {
              playerIds.add(match.player2Id!);
            }
          }
        }
      }

      // ── Single batch Firestore call for all players ──
      final players = await UserController.instance
          .getMultipleUsers(playerIds.toList());
      final playerMap = {for (final p in players) p.id: p};

      // ── Build break models ──
      final allBreaks = <HighestBreakModel>[];
      final evBreaks = <HighestBreakModel>[];
      final pracBreaks = <HighestBreakModel>[];

      for (final raw in rawBreaks) {
        final player = raw.playerId != null ? playerMap[raw.playerId] : null;
        final name = player != null && player.firstName.isNotEmpty
            ? player.firstName
            : raw.fallbackName;
        final image = player?.profilePicture ?? '';

        final model = HighestBreakModel(
          playerName: name,
          playerImage: image,
          breakScore: raw.score,
          matchType: raw.isPractice ? 'practice' : 'tournament',
        );

        allBreaks.add(model);
        if (raw.isPractice) {
          pracBreaks.add(model);
        } else {
          evBreaks.add(model);
        }
      }

      // ── Sort descending ──
      allBreaks.sort((a, b) => b.breakScore.compareTo(a.breakScore));
      evBreaks.sort((a, b) => b.breakScore.compareTo(a.breakScore));
      pracBreaks.sort((a, b) => b.breakScore.compareTo(a.breakScore));

      topBreaks.assignAll(allBreaks.take(50));
      eventBreaks.assignAll(evBreaks.take(50));
      practiceBreaks.assignAll(pracBreaks.take(50));

      _saveToCache();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: '_processSnapshot error');
    }
  }

  // ── Cache ──────────────────────────────────────────────
  void _saveToCache() {
    try {
      _storage.write(_cacheKeyAll, topBreaks.map((b) => b.toJson()).toList());
      _storage.write(_cacheKeyEvent, eventBreaks.map((b) => b.toJson()).toList());
      _storage.write(_cacheKeyPractice, practiceBreaks.map((b) => b.toJson()).toList());
      _storage.write(_cacheKeyTimestamp, DateTime.now().toIso8601String());
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: '_saveToCache error');
    }
  }

  void _loadFromCache() {
    try {
      final all = _storage.read(_cacheKeyAll);
      if (all != null) {
        topBreaks.assignAll(
          (all as List).map((e) => HighestBreakModel.fromJson(Map<String, dynamic>.from(e))),
        );
      }
      final ev = _storage.read(_cacheKeyEvent);
      if (ev != null) {
        eventBreaks.assignAll(
          (ev as List).map((e) => HighestBreakModel.fromJson(Map<String, dynamic>.from(e))),
        );
      }
      final prac = _storage.read(_cacheKeyPractice);
      if (prac != null) {
        practiceBreaks.assignAll(
          (prac as List).map((e) => HighestBreakModel.fromJson(Map<String, dynamic>.from(e))),
        );
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: '_loadFromCache error');
    }
  }

  // ── Helpers ────────────────────────────────────────────
  Map<String, dynamic> _safeMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    return Map<String, dynamic>.from(
      (value as Map).map((k, v) => MapEntry(k.toString(), v)),
    );
  }
}

// ── Internal raw break before player lookup ────────────
class _RawBreak {
  final String? playerId;
  final String fallbackName;
  final int score;
  final bool isPractice;

  const _RawBreak({
    required this.playerId,
    required this.fallbackName,
    required this.score,
    required this.isPractice,
  });
}

// ── Model ──────────────────────────────────────────────
class HighestBreakModel {
  final String playerName;
  final String playerImage;
  final int breakScore;
  final String matchType;

  const HighestBreakModel({
    required this.playerName,
    required this.playerImage,
    required this.breakScore,
    this.matchType = 'tournament',
  });

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'playerImage': playerImage,
    'breakScore': breakScore,
    'matchType': matchType,
  };

  factory HighestBreakModel.fromJson(Map<String, dynamic> json) =>
      HighestBreakModel(
        playerName: json['playerName'] ?? '',
        playerImage: json['playerImage'] ?? '',
        breakScore: json['breakScore'] ?? 0,
        matchType: json['matchType'] ?? 'tournament',
      );
}