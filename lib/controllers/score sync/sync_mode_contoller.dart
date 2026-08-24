import 'package:get/get.dart';

import '../../services/rtdb_sync_service.dart';
import '../../services/score_sync_service.dart';


/// Sync modes available — local storage is ALWAYS on regardless of this
/// (handled separately by ScoreLocalStorageService), this controller only
/// manages the cross-device sync layer (for the streaming phone).
enum SyncMode { firebase, socket, nearby, bluetooth }

/// Manages which sync transport is currently active. Defaults to Firebase
/// RTDB. If RTDB's connection monitor reports a real disconnect, flags
/// that a fallback may be needed — UI can then prompt the user to pick
/// Bluetooth/Socket/Nearby manually.
class SyncModeController extends GetxController {
  final Rx<SyncMode> currentMode = SyncMode.firebase.obs;

  /// True when RTDB reports it's disconnected — UI watches this to show
  /// a "connection lost, switch to fallback?" prompt.
  final RxBool isRtdbDisconnected = false.obs;

  ScoreSyncService? _activeService;

  ScoreSyncService get activeService {
    _activeService ??= _buildServiceFor(currentMode.value);
    return _activeService!;
  }

  ScoreSyncService _buildServiceFor(SyncMode mode) {
    switch (mode) {
      case SyncMode.firebase:
        final rtdb = RtdbSyncService();
        // Start monitoring connection status as soon as RTDB is selected —
        // this is what detects drops and triggers auto-resync on reconnect.
        rtdb.listenForConnectionChanges(
          onStatusChanged: (isConnected) {
            isRtdbDisconnected.value = !isConnected;
            // ignore: avoid_print
            print('🟡 [SyncModeController] RTDB isDisconnected=${isRtdbDisconnected.value}');
          },
        );
        return rtdb;

    // TODO: implement SocketSyncService, NearbySyncService,
    // BluetoothSyncService as separate classes when building those.
      case SyncMode.socket:
      case SyncMode.nearby:
      case SyncMode.bluetooth:
        throw UnimplementedError('${mode.name} sync not implemented yet — only Firebase RTDB is ready.');
    }
  }

  /// Called when the user manually picks a fallback mode from a prompt
  /// (shown when isRtdbDisconnected is true).
  void switchTo(SyncMode mode) {
    // ignore: avoid_print
    print('🟠 [SyncModeController] Switching sync mode to ${mode.name}');
    _activeService?.dispose();
    currentMode.value = mode;
    _activeService = _buildServiceFor(mode);
  }

  /// Sends the current score state through whichever transport is active.
  /// Caller (ScoringScreen) doesn't need to know which one is running.
  Future<void> sendUpdate(String matchId, Map<String, dynamic> scoreJson) async {
    await activeService.sendUpdate(matchId, scoreJson);
  }

  @override
  void onClose() {
    _activeService?.dispose();
    super.onClose();
  }
}