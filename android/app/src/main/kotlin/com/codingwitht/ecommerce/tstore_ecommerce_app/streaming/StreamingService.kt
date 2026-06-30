package com.cuex.app.streaming

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraCharacteristics
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.pedro.common.ConnectChecker
import com.pedro.library.generic.GenericStream
import com.cuex.app.R

/**
 * StreamingService - Main foreground service for live streaming
 *
 * This service keeps streaming alive when:
 * - App goes to background
 * - Screen turns off
 * - User switches apps
 *
 * Delegates work to specialized managers:
 * - StreamConnectionManager: RTMP connection & reconnection
 * - StreamHealthMonitor: Stream quality monitoring
 * - ScoreboardManager: Scoreboard overlay management
 * - AdaptiveBitrateManager: Dynamic bitrate adjustment
 */
@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
class StreamingService : Service(), ConnectChecker {

    companion object {
        private const val TAG = "StreamingService"

        var INSTANCE: StreamingService? = null

        const val ACTION_START_STREAM = "com.cuex.app.START_STREAM"
        const val ACTION_STOP_STREAM = "com.cuex.app.STOP_STREAM"
        const val ACTION_UPDATE_SCOREBOARD = "com.cuex.app.UPDATE_SCOREBOARD"

        const val EXTRA_RTMP_URL = "rtmp_url"
        const val EXTRA_STREAM_KEY = "stream_key"
        const val EXTRA_MATCH_DATA = "match_data"
        const val ACTION_SHOW_BREAK = "com.cuex.app.SHOW_BREAK"
        const val ACTION_HIDE_BREAK = "com.cuex.app.HIDE_BREAK"
    }

    // ============================================
    // SERVICE COMPONENTS
    // ============================================

    /** Notification manager */
    private var notificationManager: NotificationManager? = null

    /** Pedro library's GenericStream */
    private var genericStream: GenericStream? = null

    /** Connection manager (handles RTMP connection) */
    private var connectionManager: StreamConnectionManager? = null

    /** Health monitor (tracks stream quality) */
    private val healthMonitor = StreamHealthMonitor()

    /** Scoreboard manager (handles overlay) */
    private var scoreboardManager: ScoreboardManager? = null

    /** Adaptive bitrate manager (adjusts quality based on network) */
    private var adaptiveBitrateManager: AdaptiveBitrateManager? = null

    /** Bitrate monitoring handler */
    private var bitrateMonitorHandler: android.os.Handler? = null
    private var bitrateMonitorRunnable: Runnable? = null

    /** External callback listener */
    private var callback: ConnectChecker? = null

    /** Stream preparation state */
    private var isPrepared = false

    private var audioMuted = false


    // ============================================
    // SERVICE LIFECYCLE
    // ============================================

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🟢 StreamingService onCreate()")

        // Setup notification channel
        setupNotificationChannel()

        // Set singleton instance
        INSTANCE = this

        Log.d(TAG, "✅ Service created")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "📨 onStartCommand() - Action: ${intent?.action}")

        when (intent?.action) {
            StreamingConstants.ACTION_START_STREAM -> handleStartStream(intent)
            StreamingConstants.ACTION_STOP_STREAM -> handleStopStream()
            StreamingConstants.ACTION_UPDATE_SCOREBOARD -> handleUpdateScoreboard(intent)
            StreamingConstants.ACTION_SHOW_BREAK -> scoreboardManager?.showBreakScreen()
            StreamingConstants.ACTION_HIDE_BREAK -> scoreboardManager?.hideBreakScreen()
        }

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "🔴 onDestroy() - Service shutting down")

        // Stop monitoring
        stopBitrateMonitoring()

        // Cleanup resources
        connectionManager?.stopStream()
        connectionManager?.release()
        scoreboardManager?.release()
        healthMonitor.reset()
        adaptiveBitrateManager = null

        if (genericStream?.isStreaming == true) {
            genericStream?.stopStream()
        }
        if (genericStream?.isOnPreview == true) {
            genericStream?.stopPreview()
        }

        genericStream?.release()
        genericStream = null

        INSTANCE = null
        Log.d(TAG, "✅ Service destroyed")
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // Don't stop - let stream continue
        super.onTaskRemoved(rootIntent)
    }

    // ============================================
    // NOTIFICATION MANAGEMENT
    // ============================================

    /**
     * Setup notification channel for Android O+
     */
    private fun setupNotificationChannel() {
        notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.d(TAG, "📱 Creating notification channel")
            val channel = NotificationChannel(
                StreamingConstants.CHANNEL_ID,
                "Live Streaming",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows when live streaming is active"
                setShowBadge(false)
            }
            notificationManager?.createNotificationChannel(channel)
        }
    }

    /**
     * Start foreground notification
     */
    private fun startForegroundNotification(title: String, text: String) {
        Log.d(TAG, "🔔 Starting foreground notification: $title")

        val notification = NotificationCompat.Builder(this, StreamingConstants.CHANNEL_ID)
            .setSmallIcon(R.drawable.notification_icon)
            .setContentTitle(title)
            .setContentText(text)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setSilent(true)
            .build()

        startForeground(StreamingConstants.NOTIFY_ID, notification)
    }

    /**
     * Update notification
     */
    private fun updateNotification(title: String, text: String) {
        Log.d(TAG, "📝 Updating notification: $title")

        val notification = NotificationCompat.Builder(this, StreamingConstants.CHANNEL_ID)
            .setSmallIcon(R.drawable.notification_icon)
            .setContentTitle(title)
            .setContentText(text)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setSilent(true)
            .build()

        notificationManager?.notify(StreamingConstants.NOTIFY_ID, notification)
    }

    // ============================================
    // STREAM PREPARATION
    // ============================================

    /**
     * Prepare stream with camera, encoders, and scoreboard
     *
     * @param matchData Match information for scoreboard
     * @param width Video width (default 1920)
     * @param height Video height (default 1080)
     * @param bitrate Video bitrate (default 10 Mbps)
     */
    fun prepareStream(
        matchData: Map<String, Any>,
        width: Int = StreamingConstants.VIDEO_WIDTH,
        height: Int = StreamingConstants.VIDEO_HEIGHT,
        bitrate: Int = StreamingConstants.VIDEO_BITRATE
    ): Boolean {
        Log.d(TAG, "🎥 prepareStream() called")
        Log.d(TAG, "📹 Quality: ${width}x${height} @ ${bitrate / 1024} kbps")

        try {
            // Start as foreground service
            startForegroundNotification("Preparing Stream", "Setting up camera...")

            // Get surface from CameraPreview
            val surface = CameraPreview.sharedSurfaceView
            if (surface == null) {
                Log.e(TAG, "❌ Surface not ready")
                return false
            }

            // Release old stream if exists
            if (genericStream != null) {
                Log.d(TAG, "♻️ Releasing old stream...")
                genericStream?.release()
            }

            // Create GenericStream
            Log.d(TAG, "🆕 Creating GenericStream...")
            genericStream = GenericStream(applicationContext, this).apply {
                getGlInterface().autoHandleOrientation = true
                getGlInterface().setForceRender(true)
            }

            // Prepare video encoder with dynamic quality
            Log.d(TAG, "📹 Preparing video encoder with custom quality...")
            val videoPrepared = genericStream!!.prepareVideo(
                width = width,
                height = height,
                bitrate = bitrate,
                fps = StreamingConstants.VIDEO_FPS,
                rotation = StreamingConstants.VIDEO_ROTATION
            )

            // Prepare audio encoder
            Log.d(TAG, "🎤 Preparing audio encoder...")
            val audioPrepared = genericStream!!.prepareAudio(
                sampleRate = StreamingConstants.AUDIO_SAMPLE_RATE,
                isStereo = StreamingConstants.AUDIO_IS_STEREO,
                bitrate = StreamingConstants.AUDIO_BITRATE,
                echoCanceler = StreamingConstants.AUDIO_ECHO_CANCEL,
                noiseSuppressor = StreamingConstants.AUDIO_NOISE_SUPPRESS
            )

            if (!videoPrepared || !audioPrepared) {
                Log.e(TAG, "❌ Encoder preparation failed")
                return false
            }

            Log.d(TAG, "✅ Encoders prepared")

            // Create managers
            connectionManager = StreamConnectionManager(genericStream, this)
            scoreboardManager = ScoreboardManager(applicationContext, genericStream)

            // Initialize adaptive bitrate manager if enabled
            if (StreamingConstants.ENABLE_VBR) {
                Log.d(TAG, "🔄 Initializing adaptive bitrate manager...")
                adaptiveBitrateManager = AdaptiveBitrateManager(
                    genericStream = genericStream,
                    initialBitrate = bitrate,
                    minBitrate = StreamingConstants.MIN_BITRATE,
                    maxBitrate = bitrate // Don't exceed selected quality
                )
                Log.d(TAG, "✅ Adaptive bitrate manager initialized")
            } else {
                Log.d(TAG, "⚠️ Adaptive bitrate disabled (VBR off)")
            }

            // Create scoreboard
            scoreboardManager?.createScoreboard(matchData)

            // Start camera preview
            Log.d(TAG, "📷 Starting camera preview...")
            // After starting preview
            if (surface.holder.surface.isValid) {
                genericStream?.startPreview(surface)

                // Enable camera features
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    when (val videoSource = genericStream?.videoSource) {
                        is com.pedro.encoder.input.sources.video.Camera2Source -> {
                            // Enable auto focus
                            val autoFocusEnabled = videoSource.enableAutoFocus()
                            Log.d(TAG, if (autoFocusEnabled) "✅ Auto focus enabled" else "⚠️ Auto focus not supported")

                            // Enable video stabilization
                            val stabilizationEnabled = videoSource.enableVideoStabilization()
                            Log.d(TAG, if (stabilizationEnabled) "✅ Video stabilization enabled" else "⚠️ Video stabilization not supported")

                            // Optical stabilization (if hardware supports)
                            val oisEnabled = videoSource.enableOpticalVideoStabilization()
                            Log.d(TAG, if (oisEnabled) "✅ Optical stabilization enabled" else "⚠️ OIS not supported")
                        }
                    }
                }, 1500)

                Log.d(TAG, "✅ Camera preview started")
            }

            isPrepared = true
            Log.d(TAG, "✅ Stream preparation complete")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error preparing stream: ${e.message}", e)
            isPrepared = false
            return false
        }
    }
    fun setExposure(offset: Int) {
        val source = genericStream?.videoSource as? com.pedro.encoder.input.sources.video.Camera2Source
        source?.setExposure(offset)
        Log.d(TAG, "✅ Exposure set: $offset")
    }
    /**
     * Restart camera preview (after app returns from background)
     */
    fun restartPreview() {
        try {
            Log.d(TAG, "🔄 Restarting camera preview...")

            val surface = CameraPreview.sharedSurfaceView
            if (surface != null && genericStream != null) {
                genericStream?.stopPreview()
                genericStream?.startPreview(surface)
                Log.d(TAG, "✅ Preview restarted")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error restarting preview: $e")
        }
    }

    // ============================================
    // INTENT HANDLERS
    // ============================================

    /**
     * Handle ACTION_START_STREAM
     */
    private fun handleStartStream(intent: Intent) {
        Log.d(TAG, "🎬 Handling ACTION_START_STREAM")

        val rtmpUrl = intent.getStringExtra(StreamingConstants.EXTRA_RTMP_URL)
        val streamKey = intent.getStringExtra(StreamingConstants.EXTRA_STREAM_KEY)
        val matchData = intent.getSerializableExtra(StreamingConstants.EXTRA_MATCH_DATA) as? HashMap<String, Any>

        if (rtmpUrl == null || streamKey == null || matchData == null) {
            Log.e(TAG, "❌ Missing parameters")
            return
        }

        // Prepare if not already prepared
        if (!isPrepared) {
            Log.d(TAG, "⚙️ Stream not prepared, preparing now...")
            if (!prepareStream(matchData)) {
                Log.e(TAG, "❌ Failed to prepare stream")
                callback?.onConnectionFailed("Failed to prepare stream")
                return
            }
        }

        // CHECK IF PREVIEW IS RUNNING
        if (genericStream?.isOnPreview != true) {
            Log.e(TAG, "❌ Preview not active, cannot start stream")
            callback?.onConnectionFailed("Camera preview must be started first")
            return
        }

        // Start streaming via connection manager
        val started = connectionManager?.startStream(rtmpUrl, streamKey) ?: false
        if (started) {
            updateNotification("🔴 Starting", "Connecting to YouTube...")
        }
    }

    /**
     * Handle ACTION_STOP_STREAM
     */
    private fun handleStopStream() {
        Log.d(TAG, "⏹️ Handling ACTION_STOP_STREAM")

        stopBitrateMonitoring()
        adaptiveBitrateManager?.reset()

        connectionManager?.stopStream()
        updateNotification("Stream Ended", "Stream has been stopped")
    }

    /**
     * Handle ACTION_UPDATE_SCOREBOARD
     */
    private fun handleUpdateScoreboard(intent: Intent) {
        Log.d(TAG, "📊 Handling ACTION_UPDATE_SCOREBOARD")

        val matchData = intent.getSerializableExtra(StreamingConstants.EXTRA_MATCH_DATA) as? HashMap<String, Any>
        if (matchData != null) {
            scoreboardManager?.updateScoreboard(matchData)
        }
    }
    /**
     * Tap to focus at coordinates
     */
    fun tapToFocus(x: Float, y: Float, viewWidth: Float, viewHeight: Float): Boolean {
        try {
            Log.d(TAG, "👆 Tap to focus at: ($x, $y)")

            // Create a fake view for tap coordinates
            val fakeView = android.view.View(applicationContext).apply {
                layout(0, 0, viewWidth.toInt(), viewHeight.toInt())
            }

            // Create motion event
            val motionEvent = android.view.MotionEvent.obtain(
                System.currentTimeMillis(),
                System.currentTimeMillis(),
                android.view.MotionEvent.ACTION_UP,
                x,
                y,
                0
            )

            when (val videoSource = genericStream?.videoSource) {
                is com.pedro.encoder.input.sources.video.Camera2Source -> {
                    val focused = videoSource.tapToFocus(fakeView, motionEvent)
                    motionEvent.recycle()
                    Log.d(TAG, if (focused) "✅ Focus adjusted" else "⚠️ Focus failed")
                    return focused
                }
                else -> {
                    motionEvent.recycle()
                    Log.w(TAG, "⚠️ Tap to focus not supported")
                    return false
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error tap to focus: ${e.message}", e)
            return false
        }
    }
    fun disableAutoFocus() {
        try {
            Log.d(TAG, "🔍 Disabling auto focus...")
            when (val videoSource = genericStream?.videoSource) {
                is com.pedro.encoder.input.sources.video.Camera2Source -> {
                    videoSource.disableAutoFocus()
                    Log.d(TAG, "✅ Auto focus disabled")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error disabling auto focus: ${e.message}", e)
        }
    }

    fun enableAutoFocusManually() {
        try {
            Log.d(TAG, "🔍 Enabling auto focus...")
            when (val videoSource = genericStream?.videoSource) {
                is com.pedro.encoder.input.sources.video.Camera2Source -> {
                    videoSource.enableAutoFocus()
                    Log.d(TAG, "✅ Auto focus enabled")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error enabling auto focus: ${e.message}", e)
        }
    }
    // ============================================
    // ADAPTIVE BITRATE MONITORING
    // ============================================

    /**
     * Start monitoring bitrate and adjusting adaptively
     *
     * Uses onNewBitrate callback to feed data to adaptive manager
     */
    private fun startBitrateMonitoring() {
        if (!StreamingConstants.ENABLE_VBR || adaptiveBitrateManager == null) {
            Log.d(TAG, "⚠️ Adaptive bitrate monitoring disabled")
            return
        }

        Log.d(TAG, "📊 Adaptive bitrate monitoring enabled")
        Log.d(TAG, "   Adjustments will be made based on onNewBitrate callbacks")
    }

    /**
     * Stop bitrate monitoring
     */
    private fun stopBitrateMonitoring() {
        Log.d(TAG, "⏹️ Stopping adaptive bitrate monitoring...")
        // Monitoring happens via callbacks, nothing to explicitly stop
    }

    // ============================================
    // CAMERA CONTROLS
    // ============================================

    /**
     * Set camera zoom level
     *
     * @param zoom Zoom level (1.0 = no zoom, 5.0 = max zoom)
     */
    fun setZoom(zoom: Float) {
        try {
            Log.d(TAG, "🔍 Setting zoom to: $zoom")

            val clampedZoom = zoom.coerceIn(1.0f, 5.0f)

            when (val videoSource = genericStream?.videoSource) {
                is com.pedro.encoder.input.sources.video.Camera2Source -> {
                    videoSource.setZoom(clampedZoom)
                    Log.d(TAG, "✅ Zoom set to: $clampedZoom")
                }
                else -> {
                    Log.w(TAG, "⚠️ Zoom not supported on this camera source")
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error setting zoom: ${e.message}", e)
        }
    }

    /**
     * Switch between front and back camera
     */
    fun switchCamera() {
        try {
            Log.d(TAG, "🔄 Switching camera...")

            when (val videoSource = genericStream?.videoSource) {
                is com.pedro.encoder.input.sources.video.Camera2Source -> {
                    videoSource.switchCamera()
                    Log.d(TAG, "✅ Camera switched")
                }
                else -> {
                    Log.w(TAG, "⚠️ Camera switch not supported on this source")
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error switching camera: ${e.message}", e)
        }
    }

    /**
     * Get camera capabilities
     *
     * Returns supported resolutions, FPS, and other camera info
     */
    fun getCameraCapabilities(): Map<String, Any> {
        try {
            Log.d(TAG, "📷 Getting camera capabilities...")

            val cameraManager = this.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val cameraId = cameraManager.cameraIdList[0]
            val characteristics = cameraManager.getCameraCharacteristics(cameraId)

            val streamConfigMap = characteristics.get(
                android.hardware.camera2.CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP
            )

            val supportedSizes = streamConfigMap?.getOutputSizes(android.graphics.ImageFormat.YUV_420_888)
            val resolutions = supportedSizes?.map { size ->
                mapOf(
                    "width" to size.width,
                    "height" to size.height,
                    "label" to when {
                        size.width >= 3840 -> "4K (${size.width}x${size.height})"
                        size.width >= 1920 -> "1080p (${size.width}x${size.height})"
                        size.width >= 1280 -> "720p (${size.width}x${size.height})"
                        else -> "${size.width}x${size.height}"
                    }
                )
            }?.toList() ?: emptyList()

            val fpsRanges = characteristics.get(
                android.hardware.camera2.CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES
            )

            val supportedFps = fpsRanges?.map { range ->
                mapOf(
                    "min" to range.lower,
                    "max" to range.upper,
                    "label" to "${range.upper} FPS"
                )
            }?.distinctBy { it["max"] }?.toList() ?: emptyList()

            val hardwareLevel = characteristics.get(
                android.hardware.camera2.CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL
            )

            val hardwareLevelStr = when (hardwareLevel) {
                android.hardware.camera2.CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY -> "Legacy"
                android.hardware.camera2.CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED -> "Limited"
                android.hardware.camera2.CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_FULL -> "Full"
                android.hardware.camera2.CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_3 -> "Level 3"
                else -> "Unknown"
            }

            val capabilities = mapOf(
                "resolutions" to resolutions,
                "fpsRanges" to supportedFps,
                "hardwareLevel" to hardwareLevelStr,
                "maxDigitalZoom" to (characteristics.get(
                    android.hardware.camera2.CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM
                ) ?: 1.0f)
            )

            Log.d(TAG, "✅ Camera capabilities retrieved")
            return capabilities

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting camera capabilities: ${e.message}", e)
            return mapOf("error" to (e.message ?: "Unknown error"))
        }
    }
    // ============================================
    // AUDIO SETTINGS
    // ============================================

    /**
     * Mute audio (disable microphone)
     */
    fun muteAudio() {
        try {
            Log.d(TAG, "🔇 Muting audio...")

            when (val audioSource = genericStream?.audioSource) {
                is com.pedro.encoder.input.audio.MicrophoneManager -> {
                    audioSource.setMicrophoneVolume(0f)
                    audioMuted = true
                    Log.d(TAG, "✅ Audio muted")
                }
                else -> {
                    Log.w(TAG, "⚠️ Audio source is not MicrophoneManager")
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error muting audio: ${e.message}", e)
        }
    }

    /**
     * Unmute audio (enable microphone)
     */
    fun unmuteAudio() {
        try {
            Log.d(TAG, "🔊 Unmuting audio...")

            when (val audioSource = genericStream?.audioSource) {
                is com.pedro.encoder.input.audio.MicrophoneManager -> {
                    audioSource.setMicrophoneVolume(1.0f)
                    audioMuted = false
                    Log.d(TAG, "✅ Audio unmuted")
                }
                else -> {
                    Log.w(TAG, "⚠️ Audio source is not MicrophoneManager")
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error unmuting audio: ${e.message}", e)
        }
    }

    fun isAudioMuted(): Boolean {
        return audioMuted
    }
    // ============================================
    // STREAM HEALTH & STATUS
    // ============================================

    fun getStreamHealth(): Map<String, Any>? = healthMonitor.getHealthReport()
    fun getCurrentBitrate(): Long = healthMonitor.getCurrentBitrate()
    fun getAverageBitrate(): Long = healthMonitor.getAverageBitrate()
    fun getConnectionDuration(): Long = healthMonitor.getConnectionDuration()

    fun setAutoReconnect(enabled: Boolean) {
        connectionManager?.setAutoReconnect(enabled)
    }

    fun getReconnectionStatus(): Map<String, Any> {
        return mapOf(
            "isReconnecting" to false,
            "attemptCount" to 0,
            "maxAttempts" to StreamingConstants.MAX_RECONNECT_ATTEMPTS
        )
    }

    fun getConnectionStatus(): Map<String, Any> {
        return mapOf(
            "isStreaming" to isStreaming(),
            "isConnected" to (genericStream?.isStreaming ?: false),
            "connectionState" to if (isStreaming()) "connected" else "disconnected",
            "streamHealth" to (healthMonitor.getHealthReport() ?: emptyMap<String, Any>())
        )
    }

    // ============================================
    // PUBLIC INTERFACE
    // ============================================

    fun isStreaming(): Boolean = connectionManager?.isStreaming() ?: false
    fun isOnPreview(): Boolean = genericStream?.isOnPreview ?: false
    fun setCallback(connectChecker: ConnectChecker?) { callback = connectChecker }
    fun showBreakScreen(): Boolean = scoreboardManager?.showBreakScreen() ?: false
    fun hideBreakScreen(): Boolean = scoreboardManager?.hideBreakScreen() ?: false

    // ============================================
    // ConnectChecker Implementation
    // ============================================

    override fun onConnectionStarted(url: String) {
        Log.d(TAG, "🔵 onConnectionStarted: $url")
        healthMonitor.onConnectionStart()
        callback?.onConnectionStarted(url)
    }

    override fun onConnectionSuccess() {
        Log.d(TAG, "✅ onConnectionSuccess - LIVE!")
        updateNotification("🔴 LIVE", "Streaming to YouTube")

        // Start adaptive bitrate monitoring
        startBitrateMonitoring()

        callback?.onConnectionSuccess()
    }

    override fun onConnectionFailed(reason: String) {
        Log.e(TAG, "❌ onConnectionFailed: $reason")
        updateNotification("❌ Connection Failed", reason)

        stopBitrateMonitoring()

        callback?.onConnectionFailed(reason)
    }

    override fun onNewBitrate(bitrate: Long) {
        Log.d(TAG, "📊 onNewBitrate: ${bitrate / 1000} kbps")

        healthMonitor.updateBitrate(bitrate)

        // Update adaptive bitrate manager
        if (StreamingConstants.ENABLE_VBR && adaptiveBitrateManager != null) {
            adaptiveBitrateManager?.updateMeasurement(bitrate, 0)
        }

        callback?.onNewBitrate(bitrate)
    }

    override fun onDisconnect() {
        Log.d(TAG, "🔌 onDisconnect")
        updateNotification("Disconnected", "Stream has ended")

        stopBitrateMonitoring()

        callback?.onDisconnect()
    }

    override fun onAuthError() {
        Log.e(TAG, "🔐 onAuthError")
        updateNotification("❌ Auth Error", "Invalid stream key")

        stopBitrateMonitoring()

        callback?.onAuthError()
    }

    override fun onAuthSuccess() {
        Log.d(TAG, "✅ onAuthSuccess")
        callback?.onAuthSuccess()
    }
}