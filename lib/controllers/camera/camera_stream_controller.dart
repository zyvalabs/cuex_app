import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Bridges Flutter to the native StreamingHandler (Kotlin) via the exact
/// existing method channel (com.cuex.app/streaming) and event channel
/// (com.cuex.app/streaming_events) already built in the native codebase.
///
/// Covers the ENTIRE camera/streaming session lifecycle in one controller —
/// preview, going live, ending, zoom/focus/exposure/camera-switch, mute,
/// and live connection/bitrate status — since it's all one cohesive
/// session, not separate concerns.
class CameraStreamController extends GetxController {
  static const _methodChannel = MethodChannel('com.cuex.app/streaming');
  static const _eventChannel = EventChannel('com.cuex.app/streaming_events');

  // ---------------- Preview / streaming state ----------------
  final RxBool isPreviewActive = false.obs;
  final RxBool isStreaming = false.obs;
  final RxBool isConnected = false.obs; // RTMP connection specifically, not just "streaming started"

  // ---------------- Camera controls ----------------
  final RxDouble zoomLevel = 1.0.obs;
  final RxBool isAudioMuted = false.obs;

  // ---------------- Live health/status (from EventChannel) ----------------
  final RxInt currentBitrateKbps = 0.obs;
  final RxInt averageBitrateKbps = 0.obs;
  final RxInt connectionDurationSeconds = 0.obs;
  final RxnString lastError = RxnString();

  @override
  void onInit() {
    super.onInit();
    _listenToStreamEvents();
  }

  /// Listens to the native EventChannel for real-time updates — connection
  /// started/success/failed, bitrate changes, disconnects, auth errors.
  /// Native side pushes these automatically; we just reflect them into
  /// reactive state here so any screen can react without polling.
  void _listenToStreamEvents() {
    _eventChannel.receiveBroadcastStream().listen(
          (event) {
        final map = Map<String, dynamic>.from(event as Map);
        final type = map['type'] as String?;

        // ignore: avoid_print
        print('🟡 [CameraStreamController] Event received: $type — $map');

        switch (type) {
          case 'connectionStarted':
            isConnected.value = false; // still connecting, not yet confirmed
            break;
          case 'connectionSuccess':
            isConnected.value = true;
            isStreaming.value = true;
            lastError.value = null;
            break;
          case 'connectionFailed':
            isConnected.value = false;
            isStreaming.value = false;
            lastError.value = map['reason'] as String?;
            break;
          case 'bitrateChanged':
            currentBitrateKbps.value = ((map['bitrate'] as num?) ?? 0) ~/ 1000;
            break;
          case 'disconnected':
            isConnected.value = false;
            isStreaming.value = false;
            break;
          case 'authError':
            isConnected.value = false;
            isStreaming.value = false;
            lastError.value = 'Authentication failed — check stream key';
            break;
          case 'authSuccess':
          // no state change needed, just informational
            break;
        }
      },
      onError: (e) {
        // ignore: avoid_print
        print('🔴 [CameraStreamController] Event stream error: $e');
      },
    );
  }

  // ---------------- Preview ----------------

  /// Starts camera preview with scoreboard overlay. matchData must include
  /// whatever keys ScoreboardManager expects (player names, scores, etc.)
  /// so the scoreboard renders correctly from the very first frame.
  Future<bool> startPreview(Map<String, dynamic> matchData, {int width = 1920, int height = 1080, int bitrate = 10000 * 1024}) async {
    try {
      // ignore: avoid_print
      print('🔵 [CameraStreamController] startPreview() called');
      final result = await _methodChannel.invokeMethod('startPreview', {
        'matchData': matchData,
        'width': width,
        'height': height,
        'bitrate': bitrate,
      });
      isPreviewActive.value = result == true;
      // ignore: avoid_print
      print('🟢 [CameraStreamController] startPreview result: $result');
      return isPreviewActive.value;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] startPreview FAILED: $e');
      return false;
    }
  }

  Future<void> stopPreview() async {
    try {
      await _methodChannel.invokeMethod('stopPreview');
      isPreviewActive.value = false;
      // ignore: avoid_print
      print('🟢 [CameraStreamController] Preview stopped');
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] stopPreview FAILED: $e');
    }
  }

  Future<void> restartPreview() async {
    try {
      await _methodChannel.invokeMethod('restartPreview');
      // ignore: avoid_print
      print('🟢 [CameraStreamController] Preview restarted');
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] restartPreview FAILED: $e');
    }
  }

  // ---------------- Go Live / End Stream ----------------

  /// Starts the actual RTMP push to YouTube (or RTMP target). Preview must
  /// already be active — native side checks this too and errors if not.
  Future<bool> goLive({
    required String rtmpUrl,
    required String streamKey,
    Map<String, dynamic>? matchData,
  }) async {
    try {
      // ignore: avoid_print
      print('🔵 [CameraStreamController] goLive() called for $rtmpUrl');
      final result = await _methodChannel.invokeMethod('startStreaming', {
        'rtmpUrl': rtmpUrl,
        'streamKey': streamKey,
        if (matchData != null) 'matchData': matchData,
      });
      // ignore: avoid_print
      print('🟢 [CameraStreamController] goLive result: $result');
      return result == true;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] goLive FAILED: $e');
      lastError.value = e.toString();
      return false;
    }
  }

  Future<void> endStream() async {
    try {
      await _methodChannel.invokeMethod('stopStreaming');
      isStreaming.value = false;
      isConnected.value = false;
      // ignore: avoid_print
      print('🟢 [CameraStreamController] Stream ended');
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] endStream FAILED: $e');
    }
  }

  // ---------------- Scoreboard updates ----------------

  /// Pushes fresh match data to the already-running scoreboard overlay —
  /// call this whenever score/frame/break state changes during the match.
  Future<void> updateScoreboard(Map<String, dynamic> matchData) async {
    try {
      await _methodChannel.invokeMethod('updateScoreboard', {'matchData': matchData});
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] updateScoreboard FAILED: $e');
    }
  }

  // ---------------- Camera controls ----------------

  Future<void> setZoom(double zoom) async {
    try {
      await _methodChannel.invokeMethod('setZoom', {'zoom': zoom});
      zoomLevel.value = zoom;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] setZoom FAILED: $e');
    }
  }

  Future<void> zoomIn() => setZoom((zoomLevel.value + 0.5).clamp(1.0, 5.0));
  Future<void> zoomOut() => setZoom((zoomLevel.value - 0.5).clamp(1.0, 5.0));

  Future<void> switchCamera() async {
    try {
      await _methodChannel.invokeMethod('switchCamera');
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] switchCamera FAILED: $e');
    }
  }

  /// x/y are tap coordinates within the preview surface; width/height are
  /// the surface's current dimensions — needed by native tapToFocus logic.
  Future<void> tapToFocus(double x, double y, double width, double height) async {
    try {
      await _methodChannel.invokeMethod('tapToFocus', {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      });
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] tapToFocus FAILED: $e');
    }
  }

  Future<void> setExposure(int offset) async {
    try {
      await _methodChannel.invokeMethod('setExposure', {'offset': offset});
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] setExposure FAILED: $e');
    }
  }

  // ---------------- Audio ----------------

  Future<void> muteAudio() async {
    try {
      await _methodChannel.invokeMethod('muteAudio');
      isAudioMuted.value = true;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] muteAudio FAILED: $e');
    }
  }

  Future<void> unmuteAudio() async {
    try {
      await _methodChannel.invokeMethod('unmuteAudio');
      isAudioMuted.value = false;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] unmuteAudio FAILED: $e');
    }
  }

  // ---------------- Break screen ----------------

  Future<void> showBreakScreen() async {
    try {
      await _methodChannel.invokeMethod('showBreakScreen');
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] showBreakScreen FAILED: $e');
    }
  }

  Future<void> hideBreakScreen() async {
    try {
      await _methodChannel.invokeMethod('hideBreakScreen');
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] hideBreakScreen FAILED: $e');
    }
  }

  // ---------------- Status queries (pull-based, in addition to events) ----------------

  Future<Map<String, dynamic>?> getConnectionStatus() async {
    try {
      final result = await _methodChannel.invokeMethod('getConnectionStatus');
      return result != null ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [CameraStreamController] getConnectionStatus FAILED: $e');
      return null;
    }
  }

  @override
  void onClose() {
    if (isPreviewActive.value) stopPreview();
    super.onClose();
  }
}