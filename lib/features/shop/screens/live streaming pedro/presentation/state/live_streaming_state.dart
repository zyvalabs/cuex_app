// // lib/features/live streaming pedro/presentation/state/live_streaming_state.dart
//
// /// Stream health data
// class StreamHealth {
//   final int currentBitrate; // kbps
//   final int averageBitrate; // kbps
//   final int duration; // seconds
//   final String quality; // '🟢 GOOD', '🟡 FAIR', '🔴 LOW'
//
//   const StreamHealth({
//     this.currentBitrate = 0,
//     this.averageBitrate = 0,
//     this.duration = 0,
//     this.quality = 'Unknown',
//   });
//
//   StreamHealth copyWith({
//     int? currentBitrate,
//     int? averageBitrate,
//     int? duration,
//     String? quality,
//   }) {
//     return StreamHealth(
//       currentBitrate: currentBitrate ?? this.currentBitrate,
//       averageBitrate: averageBitrate ?? this.averageBitrate,
//       duration: duration ?? this.duration,
//       quality: quality ?? this.quality,
//     );
//   }
//
//   /// Get quality color
//   String get qualityColor {
//     if (quality.contains('🟢')) return '#10B981'; // green
//     if (quality.contains('🟡')) return '#F59E0B'; // amber
//     if (quality.contains('🔴')) return '#EF4444'; // red
//     return '#6B7280'; // gray
//   }
//
//   /// Get quality icon
//   String get qualityIcon {
//     if (quality.contains('🟢')) return '🟢';
//     if (quality.contains('🟡')) return '🟡';
//     if (quality.contains('🔴')) return '🔴';
//     return '⚪';
//   }
//
//   /// Format bitrate for display
//   String get bitrateDisplay {
//     if (currentBitrate >= 1000) {
//       return '${(currentBitrate / 1000).toStringAsFixed(1)} Mbps';
//     }
//     return '$currentBitrate kbps';
//   }
// }
//
// /// Connection status
// enum ConnectionStatus {
//   disconnected,
//   connecting,
//   connected,
//   reconnecting,
//   live,
//   error;
//
//   String get displayText {
//     switch (this) {
//       case ConnectionStatus.disconnected:
//         return 'Disconnected';
//       case ConnectionStatus.connecting:
//         return 'Connecting...';
//       case ConnectionStatus.connected:
//         return 'Connected';
//       case ConnectionStatus.reconnecting:
//         return 'Reconnecting...';
//       case ConnectionStatus.live:
//         return '🔴 LIVE';
//       case ConnectionStatus.error:
//         return 'Error';
//     }
//   }
//
//   /// Get color for status badge
//   String get colorHex {
//     switch (this) {
//       case ConnectionStatus.disconnected:
//         return '#6B7280'; // gray
//       case ConnectionStatus.connecting:
//         return '#F59E0B'; // amber
//       case ConnectionStatus.connected:
//         return '#10B981'; // green
//       case ConnectionStatus.reconnecting:
//         return '#F59E0B'; // amber
//       case ConnectionStatus.live:
//         return '#EF4444'; // red
//       case ConnectionStatus.error:
//         return '#EF4444'; // red
//     }
//   }
// }
//
// /// Live streaming state
// class LiveStreamingState {
//   // Stream status
//   final bool isPreviewActive;
//   final bool isStreaming;
//   final bool isStartingStream;
//   final bool isStoppingStream;
//   final bool isStartingPreview;
//   // Connection
//   final ConnectionStatus connectionStatus;
//   final int reconnectAttempts;
//   final int maxReconnectAttempts;
//
//   // Stream health
//   final StreamHealth? streamHealth;
//
//   // Settings
//   final bool autoReconnectEnabled;
//
//   // RTMP credentials (cached from database)
//   final String? currentRtmpUrl;
//   final String? currentStreamKey;
//
//   // Error handling
//   final String? errorMessage;
//   final String selectedResolution;
//   final int selectedWidth;
//   final int selectedHeight;
//   final bool isAudioMuted;
//   final bool isAutoFocusEnabled;
//
//   const LiveStreamingState({
//     this.isPreviewActive = false,
//     this.isStreaming = false,
//     this.isStartingStream = false,
//     this.isStoppingStream = false,
//     this.connectionStatus = ConnectionStatus.disconnected,
//     this.reconnectAttempts = 0,
//     this.maxReconnectAttempts = 3,
//     this.streamHealth,
//     this.autoReconnectEnabled = true,
//     this.currentRtmpUrl,
//     this.currentStreamKey,
//     this.errorMessage,
//     this.isStartingPreview = false,
//     this.selectedResolution = '1080p', // Default
//     this.selectedWidth = 1920,
//     this.selectedHeight = 1080,
//     this.isAudioMuted = false,
//     this.isAutoFocusEnabled = true,
//
//
//   });
//
//   LiveStreamingState copyWith({
//     bool? isPreviewActive,
//     bool? isStreaming,
//     bool? isStartingStream,
//     bool? isStoppingStream,
//     bool? isStartingPreview,
//     ConnectionStatus? connectionStatus,
//     int? reconnectAttempts,
//     int? maxReconnectAttempts,
//     StreamHealth? streamHealth,
//     bool? autoReconnectEnabled,
//     String? currentRtmpUrl,
//     String? currentStreamKey,
//     String? errorMessage,
//     String? selectedResolution,
//     int? selectedWidth,
//     int? selectedHeight,
//     bool? isAudioMuted,
//     bool? isAutoFocusEnabled,
//   }) {
//     return LiveStreamingState(
//       isPreviewActive: isPreviewActive ?? this.isPreviewActive,
//       isStreaming: isStreaming ?? this.isStreaming,
//       isStartingStream: isStartingStream ?? this.isStartingStream,
//       isStoppingStream: isStoppingStream ?? this.isStoppingStream,
//       isStartingPreview: isStartingPreview ?? this.isStartingPreview,
//       connectionStatus: connectionStatus ?? this.connectionStatus,
//       reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
//       maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
//       streamHealth: streamHealth ?? this.streamHealth,
//       autoReconnectEnabled: autoReconnectEnabled ?? this.autoReconnectEnabled,
//       currentRtmpUrl: currentRtmpUrl ?? this.currentRtmpUrl,
//       currentStreamKey: currentStreamKey ?? this.currentStreamKey,
//       errorMessage: errorMessage ?? this.errorMessage,
//       selectedResolution: selectedResolution ?? this.selectedResolution,
//       selectedWidth: selectedWidth ?? this.selectedWidth,
//       selectedHeight: selectedHeight ?? this.selectedHeight,
//       isAudioMuted: isAudioMuted ?? this.isAudioMuted,
//       isAutoFocusEnabled: isAutoFocusEnabled ?? this.isAutoFocusEnabled,
//     );
//   }
// }