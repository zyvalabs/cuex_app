
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized Analytics & Crashlytics service for CueX
/// Usage: AppAnalytics.logEvent(...) or AppAnalytics.logError(...)
class AppAnalytics {
  static final _analytics = FirebaseAnalytics.instance;
  static final _crashlytics = FirebaseCrashlytics.instance;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // INIT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> init() async {
    // Enable crashlytics in release, disable in debug
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    // Catch all Flutter framework errors
    FlutterError.onError = _crashlytics.recordFlutterFatalError;
    // Catch async errors outside Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // USER CONTEXT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> setUser({required String userId, String? role}) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
    if (role != null) {
      await _analytics.setUserProperty(name: 'user_role', value: role);
      await _crashlytics.setCustomKey('user_role', role);
    }
  }

  static Future<void> clearUser() async {
    await _analytics.setUserId(id: null);
    await _crashlytics.setUserIdentifier('');
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ERROR LOGGING
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Log non-fatal error (keeps app running)
  static Future<void> logError(
      dynamic error,
      StackTrace? stack, {
        String? reason,
        bool fatal = false,
        Map<String, dynamic>? context,
      }) async {
    if (kDebugMode) {
      debugPrint('❌ [AppAnalytics] Error: $error\nReason: $reason');
      return;
    }
    if (context != null) {
      for (final entry in context.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value.toString());
      }
    }
    await _crashlytics.recordError(error, stack, reason: reason, fatal: fatal);
  }

  /// Log a message to crashlytics breadcrumbs
  static Future<void> log(String message) async {
    await _crashlytics.log(message);
    if (kDebugMode) debugPrint('📝 [AppAnalytics] $message');
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // AUTH EVENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
    await log('User logged in via $method');
  }

  static Future<void> logLogout() async {
    await _analytics.logEvent(name: 'user_logout');
    await log('User logged out');
  }

  static Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // YOUTUBE EVENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> logYouTubeConnected() async {
    await _analytics.logEvent(name: 'youtube_connected');
    await log('YouTube account connected');
  }

  static Future<void> logYouTubeDisconnected() async {
    await _analytics.logEvent(name: 'youtube_disconnected');
  }

  static Future<void> logYouTubeBroadcastCreated({
    required String matchId,
    required String broadcastId,
  }) async {
    await _analytics.logEvent(name: 'youtube_broadcast_created', parameters: {
      'match_id': matchId,
      'broadcast_id': broadcastId,
    });
    await log('Broadcast created: $broadcastId for match: $matchId');
  }

  static Future<void> logYouTubeError({
    required String errorType,
    required String message,
    String? matchId,
  }) async {
    await _analytics.logEvent(name: 'youtube_error', parameters: {
      'error_type': errorType,
      'message': message,
      if (matchId != null) 'match_id': matchId,
    });
    await logError(
      message,
      null,
      reason: 'YouTube API Error: $errorType',
      context: {'match_id': matchId ?? '', 'error_type': errorType},
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MATCH EVENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> logMatchCreated({
    required String matchId,
    required String eventId,
    required bool liveStreamEnabled,
  }) async {
    await _analytics.logEvent(name: 'match_created', parameters: {
      'match_id': matchId,
      'event_id': eventId,
      'live_stream_enabled': liveStreamEnabled.toString(),
    });
    await log('Match created: $matchId');
  }

  static Future<void> logMatchStarted({required String matchId}) async {
    await _analytics.logEvent(name: 'match_started', parameters: {'match_id': matchId});
  }

  static Future<void> logMatchCompleted({
    required String matchId,
    required String winnerId,
  }) async {
    await _analytics.logEvent(name: 'match_completed', parameters: {
      'match_id': matchId,
      'winner_id': winnerId,
    });
  }

  static Future<void> logScoreUpdated({
    required String matchId,
    required int player1Score,
    required int player2Score,
  }) async {
    await _analytics.logEvent(name: 'score_updated', parameters: {
      'match_id': matchId,
      'player1_score': player1Score,
      'player2_score': player2Score,
    });
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STREAMING EVENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> logStreamStarted({
    required String matchId,
    required String quality,
    required int bitrate,
  }) async {
    await _analytics.logEvent(name: 'stream_started', parameters: {
      'match_id': matchId,
      'quality': quality,
      'bitrate_kbps': bitrate ~/ 1024,
    });
    await log('Stream started for match: $matchId at $quality');
  }

  static Future<void> logStreamStopped({
    required String matchId,
    required int durationSeconds,
  }) async {
    await _analytics.logEvent(name: 'stream_stopped', parameters: {
      'match_id': matchId,
      'duration_seconds': durationSeconds,
    });
    await log('Stream stopped: $matchId, duration: ${durationSeconds}s');
  }

  static Future<void> logStreamError({
    required String matchId,
    required String error,
  }) async {
    await _analytics.logEvent(name: 'stream_error', parameters: {
      'match_id': matchId,
      'error': error,
    });
    await logError(error, null, reason: 'Stream error', context: {'match_id': matchId});
  }

  static Future<void> logStreamReconnected({required String matchId}) async {
    await _analytics.logEvent(name: 'stream_reconnected', parameters: {'match_id': matchId});
  }

  static Future<void> logCameraZoom({required double zoomLevel}) async {
    await _analytics.logEvent(name: 'camera_zoom', parameters: {'zoom_level': zoomLevel});
  }

  static Future<void> logExposureChanged({required int offset}) async {
    await _analytics.logEvent(name: 'exposure_changed', parameters: {'offset': offset});
  }

  static Future<void> logQualityChanged({
    required String quality,
    required int width,
    required int height,
  }) async {
    await _analytics.logEvent(name: 'stream_quality_changed', parameters: {
      'quality': quality,
      'resolution': '${width}x$height',
    });
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // VENUE / EVENT EVENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> logEventCreated({required String eventId}) async {
    await _analytics.logEvent(name: 'event_created', parameters: {'event_id': eventId});
  }

  static Future<void> logVenueViewed({required String venueId}) async {
    await _analytics.logEvent(name: 'venue_viewed', parameters: {'venue_id': venueId});
  }

  static Future<void> logBookingCreated({
    required String venueId,
    required String tableId,
  }) async {
    await _analytics.logEvent(name: 'booking_created', parameters: {
      'venue_id': venueId,
      'table_id': tableId,
    });
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SCREEN TRACKING
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // GENERIC EVENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<void> logEvent(
      String name, {
        Map<String, Object>? parameters,
      }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}