/// Shared contract for all score-sync transports (Firebase RTDB, local
/// WiFi socket, Nearby Connections, Bluetooth). ScoringScreen/controllers
/// only ever talk to this interface — they don't care which transport is
/// actually running underneath.
abstract class ScoreSyncService {
  /// Sends the current score state (as a plain JSON map) to whichever
  /// device is listening (the streaming phone).
  Future<void> sendUpdate(String matchId, Map<String, dynamic> scoreJson);

  /// Starts listening for connection status changes (used by RTDB to
  /// detect disconnect/reconnect). Not all transports need this —
  /// default no-op so subclasses only override what's relevant.
  void listenForConnectionChanges({required void Function(bool isConnected) onStatusChanged}) {}

  /// Cleans up any listeners/connections when no longer needed.
  void dispose() {}
}