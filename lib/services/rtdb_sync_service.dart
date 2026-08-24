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