import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'score_sync_service.dart';

/// Firebase RTDB implementation of ScoreSyncService — the default/primary
/// sync transport. Writes to a NEW path (Score_Sync/{matchId}) — separate
/// from the old Match_Stats path, since that one had reliability issues.
///
/// Monitors the special `.info/connected` RTDB path to detect real
/// connection status (not just "did my write throw an error") — when it
/// flips back to connected after a drop, automatically re-pushes whatever
/// was last saved, so the streaming phone catches up without the user
/// having to do anything.
class RtdbSyncService implements ScoreSyncService {
  final _database = FirebaseDatabase.instance;

  /// Keeps the last-sent payload in memory so we can re-push it
  /// automatically on reconnect, without needing the caller to resend.
  String? _lastMatchId;
  Map<String, dynamic>? _lastPayload;

  StreamSubscription<DatabaseEvent>? _connectionSubscription;

  DatabaseReference _refFor(String matchId) => _database.ref('Score_Sync/$matchId');

  /// One-time fetch of the current synced state for a match — used when a
  /// second device (e.g. a different phone on the same account, or a
  /// viewer) opens ScoringScreen and has no local storage for this match.
  Future<Map<String, dynamic>?> fetchOnce(String matchId) async {
    try {
      // ignore: avoid_print
      print('🔵 [RtdbSyncService] Fetching current state for $matchId...');
      final snapshot = await _refFor(matchId).get();
      if (!snapshot.exists) {
        // ignore: avoid_print
        print('🟡 [RtdbSyncService] No synced data found for $matchId');
        return null;
      }
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      // ignore: avoid_print
      print('🟢 [RtdbSyncService] Fetched: $data');
      return data;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [RtdbSyncService] fetchOnce FAILED: $e');
      return null;
    }
  }

  /// Continuously listens for updates on this match — used so a second
  /// device stays live-synced (e.g. viewing the match progress in real
  /// time from another phone), not just a one-time snapshot.
  StreamSubscription<DatabaseEvent> listenForUpdates(
      String matchId, {
        required void Function(Map<String, dynamic> data) onUpdate,
      }) {
    // ignore: avoid_print
    print('🟠 [RtdbSyncService] Listening for live updates on $matchId');

    return _refFor(matchId).onValue.listen((event) {
      if (!event.snapshot.exists) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      // ignore: avoid_print
      print('🟡 [RtdbSyncService] Remote update received for $matchId: $data');
      onUpdate(data);
    });
  }

  @override
  Future<void> sendUpdate(String matchId, Map<String, dynamic> scoreJson) async {
    _lastMatchId = matchId;
    _lastPayload = scoreJson;

    try {
      // ignore: avoid_print
      print('🔵 [RtdbSyncService] Sending update for $matchId: $scoreJson');
      await _refFor(matchId).set(scoreJson);
      // ignore: avoid_print
      print('🟢 [RtdbSyncService] Update sent successfully');
    } catch (e) {
      // Don't crash the scoring flow if RTDB write fails — local storage
      // already has the correct state; this is just the sync layer.
      // ignore: avoid_print
      print('🔴 [RtdbSyncService] sendUpdate FAILED: $e');
    }
  }

  @override
  void listenForConnectionChanges({required void Function(bool isConnected) onStatusChanged}) {
    // ignore: avoid_print
    print('🟠 [RtdbSyncService] Starting connection monitor on .info/connected');

    _connectionSubscription = _database.ref('.info/connected').onValue.listen((event) {
      final isConnected = event.snapshot.value == true;

      // ignore: avoid_print
      print('🟡 [RtdbSyncService] Connection status changed: isConnected=$isConnected');

      onStatusChanged(isConnected);

      // Auto-resync: if we just reconnected AND we have a pending payload
      // from before the drop, re-push it immediately.
      if (isConnected && _lastMatchId != null && _lastPayload != null) {
        // ignore: avoid_print
        print('🟢 [RtdbSyncService] Reconnected — auto-resyncing last known state');
        sendUpdate(_lastMatchId!, _lastPayload!);
      }
    });
  }

  @override
  void dispose() {
    // ignore: avoid_print
    print('🟠 [RtdbSyncService] Disposing connection monitor');
    _connectionSubscription?.cancel();
  }
}