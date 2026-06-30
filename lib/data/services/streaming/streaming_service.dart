// lib/features/live streaming pedro/data/services/streaming_service.dart
// COMPLETE Streaming Service with EventChannel

import 'package:flutter/services.dart';
import 'dart:async';

/// StreamingService - Flutter wrapper for native RTMP streaming
///
/// Communicates with Kotlin StreamingService via MethodChannel.
/// Receives real-time events via EventChannel.
///
/// Features:
/// - Camera preview management
/// - RTMP streaming to YouTube
/// - Scoreboard overlay updates
/// - Event-driven status updates
/// - Stream health monitoring
/// - Auto-reconnection
/// - Connection status tracking
class StreamingService {

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CONFIGURATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Method channel for communication with native Android code
  static const _channel = MethodChannel('com.cuex.app/streaming');

  /// Event channel for real-time streaming events
  static const _eventChannel = EventChannel('com.cuex.app/streaming_events');

  /// Stream for real-time events
  static Stream<Map<String, dynamic>>? _eventStream;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EVENT STREAM
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get stream of real-time streaming events
  ///
  /// Events include:
  /// - connectionStarted: RTMP connection initiated
  /// - connectionSuccess: Successfully connected and streaming
  /// - connectionFailed: Connection failed with reason
  /// - bitrateChanged: Bitrate updated (for health monitoring)
  /// - disconnected: Connection lost
  /// - authError: Authentication failed (bad stream key)
  /// - authSuccess: Authentication succeeded
  ///
  /// Example:
  /// ```dart
  /// StreamingService.streamEvents.listen((event) {
  ///   switch (event['type']) {
  ///     case 'connectionSuccess':
  ///       print('Stream is LIVE!');
  ///       break;
  ///     case 'bitrateChanged':
  ///       print('Bitrate: ${event['bitrate']} bps');
  ///       break;
  ///   }
  /// });
  /// ```
  static Stream<Map<String, dynamic>> get streamEvents {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) {
      print('📡 Event received: ${event['type']}');
      return Map<String, dynamic>.from(event as Map);
    });

    return _eventStream!;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PREVIEW MANAGEMENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Start camera preview with scoreboard overlay
  ///
  /// Initializes the camera and prepares stream for broadcasting.
  /// Call this before starting RTMP stream.
  ///
  /// Parameters:
  /// - matchData: Match information for scoreboard display
  ///
  /// Returns: true if preview started successfully
  /// Start camera preview with scoreboard overlay
  static Future<bool> startPreview(
      Map<String, dynamic> matchData, {
        int width = 1920,
        int height = 1080,
        int bitrate = 10000 * 1024,
      }) async {
    try {
      print('🎬 Starting camera preview...');
      print('   Quality: ${width}x$height @ ${bitrate ~/ 1024} kbps');
      print('   Match data keys: ${matchData.keys}');

      final result = await _channel.invokeMethod('startPreview', {
        'matchData': matchData,
        'width': width,
        'height': height,
        'bitrate': bitrate,
      });

      print('✅ Preview started: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error starting preview: $e');
      return false;
    }
  }

  /// Stop camera preview
  ///
  /// Releases camera resources.
  /// Automatically called when stream ends.
  static Future<bool> stopPreview() async {
    try {
      print('⏹️ Stopping camera preview...');

      final result = await _channel.invokeMethod('stopPreview');

      print('✅ Preview stopped: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error stopping preview: $e');
      return false;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // RTMP STREAMING
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Start RTMP streaming to YouTube
  ///
  /// Begins broadcasting camera feed to YouTube RTMP server.
  /// Preview must be started first.
  ///
  /// Parameters:
  /// - rtmpUrl: YouTube RTMP server URL (e.g., rtmp://a.rtmp.youtube.com/live2)
  /// - streamKey: Your unique YouTube stream key
  /// - matchData: Match information for scoreboard
  ///
  /// Returns: true if stream start initiated successfully
  static Future<bool> startStreaming({
    required String rtmpUrl,
    required String streamKey,
    required Map<String, dynamic> matchData,
  }) async {
    try {
      print('🚀 Starting RTMP streaming...');
      print('   RTMP URL: $rtmpUrl');
      print('   Stream Key: ${streamKey.substring(0, 10)}...');

      final result = await _channel.invokeMethod('startStreaming', {
        'rtmpUrl': rtmpUrl,
        'streamKey': streamKey,
        'matchData': matchData,
      });

      print('✅ Stream started: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error starting stream: $e');
      return false;
    }
  }

  /// Stop RTMP streaming
  ///
  /// Ends broadcast to YouTube.
  /// Preview continues running.
  ///
  /// Returns: true if stream stopped successfully
  static Future<bool> stopStreaming() async {
    try {
      print('🛑 Stopping RTMP streaming...');

      final result = await _channel.invokeMethod('stopStreaming');

      print('✅ Stream stopped: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error stopping stream: $e');
      return false;
    }
  }

  /// Check if currently streaming
  ///
  /// Returns: true if RTMP stream is active
  static Future<bool> isStreaming() async {
    try {
      final result = await _channel.invokeMethod('isStreaming');
      return result as bool;
    } catch (e) {
      print('❌ Error checking stream status: $e');
      return false;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SCOREBOARD UPDATES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Update scoreboard overlay with new match data
  ///
  /// Updates the scoreboard in real-time during live stream.
  /// Can be called while streaming to update scores.
  ///
  /// Parameters:
  /// - matchData: Updated match information
  ///
  /// Returns: true if update successful
  static Future<bool> updateScoreboard(Map<String, dynamic> matchData) async {
    try {
      print('📊 Updating scoreboard...');
      print('   Player 1 Score: ${matchData['player1Score']}');
      print('   Player 2 Score: ${matchData['player2Score']}');

      final result = await _channel.invokeMethod('updateScoreboard', {
        'matchData': matchData,
      });

      print('✅ Scoreboard updated: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error updating scoreboard: $e');
      return false;
    }
  }
  /// Mute audio (disable microphone)
  ///
  /// Stops sending audio to stream while keeping video active.
  ///
  /// Returns: true if mute successful
  static Future<bool> muteAudio() async {
    try {
      print('🔇 Muting audio...');

      final result = await _channel.invokeMethod('muteAudio');

      print('✅ Audio muted: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error muting audio: $e');
      return false;
    }
  }

  /// Unmute audio (enable microphone)
  ///
  /// Resumes sending audio to stream.
  ///
  /// Returns: true if unmute successful
  static Future<bool> unmuteAudio() async {
    try {
      print('🔊 Unmuting audio...');

      final result = await _channel.invokeMethod('unmuteAudio');

      print('✅ Audio unmuted: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error unmuting audio: $e');
      return false;
    }
  }

  /// Check if audio is currently muted
  ///
  /// Returns: true if muted, false if unmuted
  static Future<bool> isAudioMuted() async {
    try {
      final result = await _channel.invokeMethod('isAudioMuted');
      return result as bool;
    } catch (e) {
      print('❌ Error checking audio state: $e');
      return true; // Default to muted on error
    }
  }
  static Future<bool> toggleAutoFocus(bool enable) async {
    try {
      print(enable ? '🔍 Enabling auto focus...' : '🔍 Disabling auto focus...');

      final result = await _channel.invokeMethod('toggleAutoFocus', {
        'enable': enable,
      });

      return result as bool;

    } catch (e) {
      print('❌ Error toggling auto focus: $e');
      return false;
    }
  }
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CAMERA CONTROLS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Set camera zoom level
  ///
  /// Adjusts zoom during preview or live stream.
  ///
  /// Parameters:
  /// - zoom: Zoom level (1.0 = no zoom, 5.0 = max zoom)
  ///
  /// Returns: true if zoom set successfully
  static Future<bool> setZoom(double zoom) async {
    try {
      print('🔍 Setting zoom to: $zoom');

      final result = await _channel.invokeMethod('setZoom', {
        'zoom': zoom,
      });

      return result as bool;

    } catch (e) {
      print('❌ Error setting zoom: $e');
      return false;
    }
  }

  /// Switch between front and back camera
  ///
  /// Toggles camera during preview or live stream.
  ///
  /// Returns: true if switch successful
  static Future<bool> switchCamera() async {
    try {
      print('🔄 Switching camera...');

      final result = await _channel.invokeMethod('switchCamera');

      print('✅ Camera switched: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error switching camera: $e');
      return false;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STREAM HEALTH MONITORING (Deprecated - Use Event Stream)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get current stream health metrics
  ///
  /// **Deprecated:** Use `streamEvents` instead for real-time updates.
  /// This method is kept for backward compatibility.
  ///
  /// Returns map with:
  /// - duration: Connection duration in seconds
  /// - currentBitrate: Current bitrate in kbps
  /// - averageBitrate: Average bitrate in kbps
  /// - quality: Quality indicator string ('🔴 LOW', '🟡 FAIR', '🟢 GOOD')
  @Deprecated('Use streamEvents.listen() for real-time health updates')
  static Future<Map<String, dynamic>?> getStreamHealth() async {
    try {
      print('📊 Fetching stream health...');

      final result = await _channel.invokeMethod('getStreamHealth');

      if (result != null) {
        final health = Map<String, dynamic>.from(result as Map);
        print('✅ Stream health retrieved:');
        print('   Duration: ${health['duration']}s');
        print('   Current Bitrate: ${health['currentBitrate']} kbps');
        print('   Average Bitrate: ${health['averageBitrate']} kbps');
        print('   Quality: ${health['quality']}');
        return health;
      }

      return null;

    } catch (e) {
      print('❌ Error getting stream health: $e');
      return null;
    }
  }

  /// Get current bitrate in kbps
  ///
  /// **Deprecated:** Use `streamEvents` instead for real-time updates.
  @Deprecated('Use streamEvents.listen() for real-time bitrate updates')
  static Future<int> getCurrentBitrate() async {
    try {
      final result = await _channel.invokeMethod('getCurrentBitrate');
      return result as int;
    } catch (e) {
      print('❌ Error getting bitrate: $e');
      return 0;
    }
  }

  /// Get average bitrate in kbps
  ///
  /// **Deprecated:** Use `streamEvents` instead for real-time updates.
  @Deprecated('Use streamEvents.listen() for real-time bitrate updates')
  static Future<int> getAverageBitrate() async {
    try {
      final result = await _channel.invokeMethod('getAverageBitrate');
      return result as int;
    } catch (e) {
      print('❌ Error getting average bitrate: $e');
      return 0;
    }
  }

  /// Get connection duration
  ///
  /// Returns: Duration in seconds, or 0 if not connected
  static Future<int> getConnectionDuration() async {
    try {
      final result = await _channel.invokeMethod('getConnectionDuration');
      return result as int;
    } catch (e) {
      print('❌ Error getting connection duration: $e');
      return 0;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // AUTO-RECONNECTION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Enable or disable auto-reconnection
  ///
  /// When enabled, stream will automatically attempt to reconnect
  /// if connection drops unexpectedly.
  ///
  /// Parameters:
  /// - enabled: true to enable auto-reconnect, false to disable
  ///
  /// Returns: true if setting updated successfully
  static Future<bool> enableAutoReconnect(bool enabled) async {
    try {
      print('🔄 ${enabled ? "Enabling" : "Disabling"} auto-reconnect...');

      final result = await _channel.invokeMethod('enableAutoReconnect', {
        'enabled': enabled,
      });

      print('✅ Auto-reconnect ${enabled ? "enabled" : "disabled"}: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error setting auto-reconnect: $e');
      return false;
    }
  }

  /// Get reconnection status
  ///
  /// **Deprecated:** Reconnection events are now sent via `streamEvents`.
  ///
  /// Returns map with:
  /// - isReconnecting: true if currently attempting to reconnect
  /// - attemptCount: Number of reconnection attempts
  /// - maxAttempts: Maximum allowed attempts
  @Deprecated('Reconnection status is now sent via streamEvents')
  static Future<Map<String, dynamic>?> getReconnectionStatus() async {
    try {
      print('🔄 Checking reconnection status...');

      final result = await _channel.invokeMethod('getReconnectionStatus');

      if (result != null) {
        final status = Map<String, dynamic>.from(result as Map);
        print('✅ Reconnection status:');
        print('   Is Reconnecting: ${status['isReconnecting']}');
        print('   Attempt Count: ${status['attemptCount']}/${status['maxAttempts']}');
        return status;
      }

      return null;

    } catch (e) {
      print('❌ Error getting reconnection status: $e');
      return null;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CONNECTION STATUS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get detailed connection status
  ///
  /// **Deprecated:** Connection status is now sent via `streamEvents`.
  ///
  /// Returns map with:
  /// - isStreaming: true if currently streaming
  /// - isConnected: true if RTMP connected
  /// - connectionState: 'disconnected', 'connecting', 'connected', 'reconnecting'
  /// - streamHealth: Health metrics (if streaming)
  @Deprecated('Connection status is now sent via streamEvents')
  static Future<Map<String, dynamic>?> getConnectionStatus() async {
    try {
      print('📡 Checking connection status...');

      final result = await _channel.invokeMethod('getConnectionStatus');

      if (result != null) {
        final status = Map<String, dynamic>.from(result as Map);
        print('✅ Connection status:');
        print('   Is Streaming: ${status['isStreaming']}');
        print('   Connection State: ${status['connectionState']}');
        return status;
      }

      return null;

    } catch (e) {
      print('❌ Error getting connection status: $e');
      return null;
    }
  }
  /// Restart camera preview (useful after app returns from background)
  ///
  /// Restarts preview without interrupting RTMP stream.
  /// Call this when app resumes from background.
  ///
  /// Returns: true if preview restarted successfully
  static Future<bool> restartPreview() async {
    try {
      print('🔄 Restarting camera preview...');

      final result = await _channel.invokeMethod('restartPreview');

      print('✅ Preview restarted: $result');
      return result as bool;

    } catch (e) {
      print('❌ Error restarting preview: $e');
      return false;
    }
  }
  /// Get camera capabilities
  ///
  /// Returns supported resolutions, FPS ranges, and hardware info.
  /// Call this before starting preview to know what device supports.
  ///
  /// Returns map with:
  /// - resolutions: List of supported resolutions [{width, height, label}]
  /// - fpsRanges: List of supported FPS [{min, max, label}]
  /// - hardwareLevel: Camera hardware level (Legacy/Limited/Full/Level 3)
  /// - maxDigitalZoom: Maximum digital zoom level
  static Future<Map<String, dynamic>?> getCameraCapabilities() async {
    try {
      print('📷 Getting camera capabilities...');

      final result = await _channel.invokeMethod('getCameraCapabilities');

      if (result != null) {
        final capabilities = Map<String, dynamic>.from(result as Map);

        print('✅ Camera capabilities retrieved:');
        print('   Resolutions: ${(capabilities['resolutions'] as List).length} options');
        print('   FPS ranges: ${(capabilities['fpsRanges'] as List).length} options');
        print('   Hardware level: ${capabilities['hardwareLevel']}');
        print('   Max zoom: ${capabilities['maxDigitalZoom']}x');

        return capabilities;
      }

      return null;

    } catch (e) {
      print('❌ Error getting camera capabilities: $e');
      return null;
    }
  }
  static Future<bool> showBreakScreen() async {
    try {
      final result = await _channel.invokeMethod('showBreakScreen');
      return result as bool;
    } catch (e) {
      print('❌ Error showing break screen: $e');
      return false;
    }
  }

  static Future<bool> hideBreakScreen() async {
    try {
      final result = await _channel.invokeMethod('hideBreakScreen');
      return result as bool;
    } catch (e) {
      print('❌ Error hiding break screen: $e');
      return false;
    }
  }
  static Future<bool> setExposure(int offset) async {
    try {
      final result = await _channel.invokeMethod('setExposure', {'offset': offset});
      return result as bool;
    } catch (e) {
      print('❌ Error setting exposure: $e');
      return false;
    }
  }
  /// Check if preview is active
  ///
  /// Returns: true if camera preview is running
  static Future<bool> isPreviewActive() async {
    try {
      final result = await _channel.invokeMethod('isPreviewActive');
      return result as bool;
    } catch (e) {
      print('❌ Error checking preview status: $e');
      return false;
    }
  }
}