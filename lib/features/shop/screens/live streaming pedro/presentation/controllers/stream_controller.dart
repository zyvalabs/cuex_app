import 'dart:async';
import 'package:get/get.dart';

import '../../../../../../data/services/streaming/streaming_service.dart';
import '../state/stream_state.dart';

class LiveStreamController extends GetxController {
  // Observable state
  final connectionStatus = Rx<ConnectionStatus>(ConnectionStatus.disconnected);
  final isStreaming = false.obs;
  final isStarting = false.obs;
  final isStopping = false.obs;
  final autoReconnectEnabled = true.obs;
  final reconnectAttempts = 0.obs;
  final rtmpUrl = Rx<String?>(null);
  final streamKey = Rx<String?>(null);
  final streamHealth = Rx<StreamHealth?>(null);
  final error = Rx<String?>(null);

  StreamSubscription? _eventSubscription;
  Timer? _durationTimer;
  DateTime? _streamStartTime;

  @override
  void onInit() {
    super.onInit();
    _listenToStreamEvents();
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    _durationTimer?.cancel();
    super.onClose();
  }

  void _listenToStreamEvents() {
    _eventSubscription = StreamingService.streamEvents.listen((event) {
      final type = event['type'] as String;

      switch (type) {
        case 'connectionStarted':
          connectionStatus.value = ConnectionStatus.connecting;
          break;
        case 'connectionSuccess':
          _handleConnectionSuccess();
          break;
        case 'connectionFailed':
          _handleConnectionFailed(event['reason'] as String);
          break;
        case 'bitrateChanged':
          _handleBitrateChanged(event['bitrate'] as int);
          break;
        case 'disconnected':
          _handleDisconnected();
          break;
      }
    });
  }

  void _handleConnectionSuccess() {
    _streamStartTime = DateTime.now();
    _startDurationTimer();

    connectionStatus.value = ConnectionStatus.live;
    isStreaming.value = true;
    isStarting.value = false;
    reconnectAttempts.value = 0;
  }

  void _handleConnectionFailed(String reason) {
    String userMessage;
    if (reason.contains('quotaExceeded') || reason.contains('403')) {
      userMessage = '⚠️ YouTube quota limit reached!';
    } else {
      userMessage = '❌ Connection failed: $reason';
    }

    connectionStatus.value = ConnectionStatus.error;
    isStreaming.value = false;
    isStarting.value = false;
    error.value = userMessage;
  }

  void _handleBitrateChanged(int bitrate) {
    final bitrateKbps = bitrate ~/ 1000;

    String quality;
    if (bitrateKbps < 1000) {
      quality = '🔴 LOW';
    } else if (bitrateKbps < 3000) {
      quality = '🟡 FAIR';
    } else {
      quality = '🟢 GOOD';
    }

    final currentHealth = streamHealth.value;
    final avgBitrate = currentHealth != null
        ? ((currentHealth.averageBitrate * 9 + bitrateKbps) / 10).round()
        : bitrateKbps;

    streamHealth.value = StreamHealth(
      currentBitrate: bitrateKbps,
      averageBitrate: avgBitrate,
      duration: streamHealth.value?.duration ?? 0,
      quality: quality,
    );
  }

  void _handleDisconnected() {
    if (autoReconnectEnabled.value && isStreaming.value) {
      connectionStatus.value = ConnectionStatus.reconnecting;
    } else {
      connectionStatus.value = ConnectionStatus.disconnected;
      isStreaming.value = false;
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_streamStartTime != null) {
        final duration = DateTime.now().difference(_streamStartTime!).inSeconds;
        final current = streamHealth.value;
        if (current != null) {
          streamHealth.value = StreamHealth(
            currentBitrate: current.currentBitrate,
            averageBitrate: current.averageBitrate,
            duration: duration,
            quality: current.quality,
          );
        }
      }
    });
  }

  Future<void> startStreaming({
    required String rtmpUrl,
    required String streamKey,
    required Map<String, dynamic> matchData,
  }) async {
    try {
      isStarting.value = true;
      connectionStatus.value = ConnectionStatus.connecting;
      error.value = null;
      this.rtmpUrl.value = rtmpUrl;
      this.streamKey.value = streamKey;

      final success = await StreamingService.startStreaming(
        rtmpUrl: rtmpUrl,
        streamKey: streamKey,
        matchData: matchData,
      );

      if (!success) {
        await StreamingService.stopStreaming();
        isStreaming.value = false;
        isStarting.value = false;
        connectionStatus.value = ConnectionStatus.error;
      }

      _logEvent('stream_started', {'rtmp_url': rtmpUrl});
    } catch (e) {
      await StreamingService.stopStreaming();
      isStreaming.value = false;
      isStarting.value = false;
      connectionStatus.value = ConnectionStatus.error;
      error.value = e.toString();
    }
  }

  Future<void> stopStreaming() async {
    try {
      isStopping.value = true;

      await StreamingService.stopStreaming();

      _durationTimer?.cancel();
      _streamStartTime = null;

      isStreaming.value = false;
      isStopping.value = false;
      connectionStatus.value = ConnectionStatus.disconnected;
      streamHealth.value = null;

      _logEvent('stream_stopped', {'duration': streamHealth.value?.duration ?? 0});
    } catch (e) {
      isStopping.value = false;
      error.value = e.toString();
    }
  }

  Future<void> toggleAutoReconnect() async {
    try {
      final newValue = !autoReconnectEnabled.value;

      final success = await StreamingService.enableAutoReconnect(newValue);

      if (success) {
        autoReconnectEnabled.value = newValue;
      }

      _logEvent('auto_reconnect_toggled', {'enabled': newValue});
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> updateScoreboard(Map<String, dynamic> matchData) async {
    if (!isStreaming.value) return;

    try {
      await StreamingService.updateScoreboard(matchData);
    } catch (e) {
      error.value = e.toString();
    }
  }

  void _logEvent(String event, Map<String, dynamic> data) {
    print('Analytics: $event $data');
  }
}
//
// // Usage
// final streamController = Get.put(StreamController());
//
// // In UI
// Obx(() {
// if (streamController.isStreaming.value) {
// return Text('LIVE: ${streamController.streamHealth.value?.quality}');
// }
// return ElevatedButton(
// onPressed: () => streamController.startStreaming(...),
// child: Text('Start Stream'),
// );
// })