package com.cuex.app.streaming

/**
 * StreamingConstants - All constants for streaming
 *
 * Centralized location for:
 * - Service configuration
 * - Intent actions
 * - Intent extras
 * - Notification settings
 */
object StreamingConstants {

    // ============================================
    // SERVICE CONFIGURATION
    // ============================================

    /** Notification channel ID for foreground service */
    const val CHANNEL_ID = "LiveStreamChannel"

    /** Notification ID for foreground service */
    const val NOTIFY_ID = 999

    // ============================================
    // INTENT ACTIONS
    // ============================================

    /** Start RTMP streaming */
    const val ACTION_START_STREAM = "com.cuex.app.START_STREAM"

    /** Stop RTMP streaming */
    const val ACTION_STOP_STREAM = "com.cuex.app.STOP_STREAM"

    /** Update scoreboard overlay */
    const val ACTION_UPDATE_SCOREBOARD = "com.cuex.app.UPDATE_SCOREBOARD"
    const val ACTION_SHOW_BREAK = "com.cuex.app.SHOW_BREAK"
    const val ACTION_HIDE_BREAK = "com.cuex.app.HIDE_BREAK"

    // ============================================
    // INTENT EXTRAS
    // ============================================
// ============================================
// ADAPTIVE BITRATE SETTINGS
// ============================================

    /** Enable variable bitrate (adapts to network) */
    const val ENABLE_VBR = true

    /** Minimum bitrate when network is poor (2 Mbps) */
    const val MIN_BITRATE = 2000 * 1024

    /** Maximum bitrate when network is good */
    const val MAX_BITRATE = 20000 * 1024

    /** Bitrate adjustment interval (ms) */
    const val BITRATE_ADJUSTMENT_INTERVAL = 5000L
    /** RTMP server URL (e.g., rtmp://a.rtmp.youtube.com/live2) */
    const val EXTRA_RTMP_URL = "rtmp_url"

    /** YouTube stream key */
    const val EXTRA_STREAM_KEY = "stream_key"

    /** Match data for scoreboard (HashMap<String, Any>) */
    const val EXTRA_MATCH_DATA = "match_data"

    // ============================================
    // VIDEO ENCODER SETTINGS
    // ============================================

    /** Video width in pixels (landscape) */
    const val VIDEO_WIDTH = 1920

    /** Video height in pixels (landscape) */
    const val VIDEO_HEIGHT = 1080

    /** Video bitrate in kbps (10 Mbps) */
    const val VIDEO_BITRATE = 10000 * 1024

    /** Video frame rate */
    const val VIDEO_FPS = 30

    /** Video rotation (0 = landscape) */
    const val VIDEO_ROTATION = 0

    // ============================================
    // AUDIO ENCODER SETTINGS
    // ============================================

    /** Audio sample rate in Hz */
    const val AUDIO_SAMPLE_RATE = 44100

    /** Audio is stereo */
    const val AUDIO_IS_STEREO = true

    /** Audio bitrate in kbps (128 kbps) */
    const val AUDIO_BITRATE = 128 * 1024

    /** Enable echo cancellation */
    const val AUDIO_ECHO_CANCEL = true

    /** Enable noise suppression */
    const val AUDIO_NOISE_SUPPRESS = true

    // ============================================
    // SCOREBOARD SETTINGS
    // ============================================

    /** Scoreboard layout resource name */
    const val SCOREBOARD_LAYOUT = "test_ribbon"

    /** Scoreboard height in pixels */
    const val SCOREBOARD_HEIGHT = 100

    /** Scoreboard scale percentage (height / video height * 100) */
    const val SCOREBOARD_SCALE_Y = 9.26f // 100/1080 * 100

    // ============================================
    // RECONNECTION SETTINGS
    // ============================================

    /** Maximum reconnection attempts */
    const val MAX_RECONNECT_ATTEMPTS = 3

    /** Delay between reconnection attempts (ms) */
    const val RECONNECT_DELAY_MS = 3000L
}