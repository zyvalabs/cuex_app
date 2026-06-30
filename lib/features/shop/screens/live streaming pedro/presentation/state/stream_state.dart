// lib/features/streaming/domain/states/stream_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'stream_state.freezed.dart';

@freezed
class StreamState with _$StreamState {
  const factory StreamState({
    @Default(false) bool isStreaming,
    @Default(false) bool isStarting,
    @Default(false) bool isStopping,
    @Default(ConnectionStatus.disconnected) ConnectionStatus connectionStatus,
    @Default(0) int reconnectAttempts,
    @Default(3) int maxReconnectAttempts,
    @Default(true) bool autoReconnectEnabled,
    StreamHealth? streamHealth,
    String? rtmpUrl,
    String? streamKey,
    String? error,
  }) = _StreamState;
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  live,
  error;

  String get displayText {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case ConnectionStatus.live:
        return '🔴 LIVE';
      case ConnectionStatus.error:
        return 'Error';
    }
  }
}

class StreamHealth {
  final int currentBitrate;
  final int averageBitrate;
  final int duration;
  final String quality;

  const StreamHealth({
    this.currentBitrate = 0,
    this.averageBitrate = 0,
    this.duration = 0,
    this.quality = 'Unknown',
  });

  StreamHealth copyWith({
    int? currentBitrate,
    int? averageBitrate,
    int? duration,
    String? quality,
  }) {
    return StreamHealth(
      currentBitrate: currentBitrate ?? this.currentBitrate,
      averageBitrate: averageBitrate ?? this.averageBitrate,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
    );
  }
}