package com.cuex.app.streaming

import android.content.Context
import android.content.Intent
import android.util.Log
import com.pedro.common.ConnectChecker
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * StreamingHandler - Bridge between Flutter and StreamingService
 *
 * This is a thin layer that:
 * - Receives method calls from Flutter
 * - Delegates work to StreamingService
 * - Returns results back to Flutter
 * - Sends real-time events via EventChannel
 *
 * All actual streaming logic is in StreamingService (for background capability)
 */
class StreamingHandler(
    private val activity: FlutterActivity
) : MethodChannel.MethodCallHandler, ConnectChecker, EventChannel.StreamHandler {

    companion object {
        private const val TAG = "StreamingHandler"
    }

    private val context: Context = activity.applicationContext

    // Event sink for sending events to Flutter
    private var eventSink: EventChannel.EventSink? = null

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // SETUP METHODS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * Setup method channel
     */
    fun setupMethodChannel(methodChannel: MethodChannel) {
        Log.d(TAG, "📱 Setting up method channel")
        methodChannel.setMethodCallHandler(this)
    }

    /**
     * Setup event channel
     */
    fun setupEventChannel(eventChannel: EventChannel) {
        Log.d(TAG, "📡 Setting up event channel")
        eventChannel.setStreamHandler(this)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // EventChannel.StreamHandler Implementation
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "📡 Event channel listener attached")
        eventSink = events

        // Set this as callback for streaming service
        StreamingService.INSTANCE?.setCallback(this)
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "🔴 Event channel listener detached")
        eventSink = null
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Send Events to Flutter
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private fun sendEvent(event: Map<String, Any>) {
        activity.runOnUiThread {
            eventSink?.success(event)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ConnectChecker Implementation - Forward to Flutter via Events
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override fun onConnectionStarted(url: String) {
        Log.d(TAG, "🔵 Connection started: $url")
        sendEvent(mapOf(
            "type" to "connectionStarted",
            "url" to url,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    override fun onConnectionSuccess() {
        Log.d(TAG, "✅ Connection success - LIVE!")
        sendEvent(mapOf(
            "type" to "connectionSuccess",
            "timestamp" to System.currentTimeMillis()
        ))
    }

    override fun onConnectionFailed(reason: String) {
        Log.e(TAG, "❌ Connection failed: $reason")
        sendEvent(mapOf(
            "type" to "connectionFailed",
            "reason" to reason,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    override fun onNewBitrate(bitrate: Long) {
        Log.d(TAG, "📊 New bitrate: ${bitrate / 1000} kbps")
        sendEvent(mapOf(
            "type" to "bitrateChanged",
            "bitrate" to bitrate,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    override fun onDisconnect() {
        Log.d(TAG, "🔌 Disconnected")
        sendEvent(mapOf(
            "type" to "disconnected",
            "timestamp" to System.currentTimeMillis()
        ))
    }

    override fun onAuthError() {
        Log.e(TAG, "🔐 Auth error")
        sendEvent(mapOf(
            "type" to "authError",
            "timestamp" to System.currentTimeMillis()
        ))
    }

    override fun onAuthSuccess() {
        Log.d(TAG, "✅ Auth success")
        sendEvent(mapOf(
            "type" to "authSuccess",
            "timestamp" to System.currentTimeMillis()
        ))
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Method Channel Handler
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "📨 Method call received: ${call.method}")

        when (call.method) {
            "startPreview" -> handleStartPreview(call, result)
            "stopPreview" -> handleStopPreview(result)
            "startStreaming" -> handleStartStreaming(call, result)
            "stopStreaming" -> handleStopStreaming(result)
            "updateScoreboard" -> handleUpdateScoreboard(call, result)
            "isStreaming" -> handleIsStreaming(result)
            "setZoom" -> handleSetZoom(call, result)
            "switchCamera" -> handleSwitchCamera(result)
            "muteAudio" -> handleMuteAudio(result)           // ADD THIS
            "unmuteAudio" -> handleUnmuteAudio(result)       // ADD THIS
            "isAudioMuted" -> handleIsAudioMuted(result)
            "getStreamHealth" -> handleGetStreamHealth(result)
            "getCurrentBitrate" -> handleGetCurrentBitrate(result)
            "getAverageBitrate" -> handleGetAverageBitrate(result)
            "getConnectionDuration" -> handleGetConnectionDuration(result)
            "enableAutoReconnect" -> handleEnableAutoReconnect(call, result)
            "getReconnectionStatus" -> handleGetReconnectionStatus(result)
            "getConnectionStatus" -> handleGetConnectionStatus(result)
            "restartPreview" -> handleRestartPreview(result)
            "getCameraCapabilities" -> handleGetCameraCapabilities(result)
            "tapToFocus" -> handleTapToFocus(call, result)
            "setExposure" -> handleSetExposure(call, result)
            "toggleAutoFocus" -> handleToggleAutoFocus(call, result) // ADD
            "isPreviewActive" -> handleIsPreviewActive(result)
            "showBreakScreen" -> handleShowBreakScreen(result)
            "hideBreakScreen" -> handleHideBreakScreen(result)
            else -> {
                Log.w(TAG, "⚠️ Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }
    private fun handleShowBreakScreen(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            Log.d(TAG, "🟡 handleShowBreakScreen — service null: ${service == null}")
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }
            val success = service.showBreakScreen()
            result.success(success)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error showing break screen: ${e.message}", e)
            result.error("BREAK_ERROR", e.message, null)
        }
    }

    private fun handleHideBreakScreen(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }
            val success = service.hideBreakScreen()
            result.success(success)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error hiding break screen: ${e.message}", e)
            result.error("BREAK_ERROR", e.message, null)
        }
    }
    private fun handleSetExposure(call: MethodCall, result: MethodChannel.Result) {
        val offset = call.argument<Int>("offset") ?: 0
        StreamingService.INSTANCE?.setExposure(offset)
        result.success(true)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Method Handlers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * Start camera preview with scoreboard overlay
     */
    private fun handleStartPreview(call: MethodCall, result: MethodChannel.Result) {
        try {
            Log.d(TAG, "📷 Starting preview...")

            // Get match data
            @Suppress("UNCHECKED_CAST")
            val matchData = call.argument<Map<String, Any>>("matchData")
            if (matchData == null) {
                Log.e(TAG, "❌ matchData is null")
                result.error("INVALID_ARGS", "matchData required", null)
                return
            }

            // Get quality settings (with defaults)
            val width = call.argument<Int>("width") ?: 1920
            val height = call.argument<Int>("height") ?: 1080
            val bitrate = call.argument<Int>("bitrate") ?: (10000 * 1024)

            Log.d(TAG, "✅ Match data received: ${matchData.keys}")
            Log.d(TAG, "📹 Quality: ${width}x${height} @ ${bitrate / 1024} kbps")

            // Check surface
            val surface = CameraPreview.sharedSurfaceView
            if (surface == null) {
                Log.e(TAG, "❌ Surface not ready")
                result.error("NO_SURFACE", "Camera surface not ready", null)
                return
            }

            // Start service with quality settings
            val serviceIntent = Intent(context, StreamingService::class.java).apply {
                putExtra("match_data", HashMap(matchData))
                putExtra("video_width", width)
                putExtra("video_height", height)
                putExtra("video_bitrate", bitrate)
            }
            context.startService(serviceIntent)

            // Wait and prepare
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                val service = StreamingService.INSTANCE
                if (service != null) {
                    service.setCallback(this)
                    service.prepareStream(matchData, width, height, bitrate)
                }
            }, 1000)

            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error starting preview: ${e.message}", e)
            result.error("ERROR", e.message, null)
        }
    }
    // Add handler method:
    private fun handleRestartPreview(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            service.restartPreview()
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error restarting preview: ${e.message}", e)
            result.error("RESTART_ERROR", e.message, null)
        }
    }
    /**
     * Stop camera preview
     */
    private fun handleStopPreview(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "⏹️ Stopping preview...")

            val service = StreamingService.INSTANCE
            if (service != null) {
                Log.d(TAG, "🛑 Stopping service...")
                val serviceIntent = Intent(context, StreamingService::class.java)
                context.stopService(serviceIntent)
                Log.d(TAG, "✅ Service stop command sent")
            } else {
                Log.w(TAG, "⚠️ Service instance is null")
            }

            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error stopping preview: ${e.message}", e)
            result.error("ERROR", e.message, null)
        }
    }
    // Add handler method:
    /**
     * Get camera capabilities
     */
    private fun handleGetCameraCapabilities(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "📷 Getting camera capabilities...")

            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as android.hardware.camera2.CameraManager
            val cameraId = cameraManager.cameraIdList[0] // Back camera
            val characteristics = cameraManager.getCameraCharacteristics(cameraId)

            // Get supported resolutions
            val streamConfigMap = characteristics.get(
                android.hardware.camera2.CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP
            )

            val supportedSizes = streamConfigMap?.getOutputSizes(android.graphics.ImageFormat.YUV_420_888)

            // Filter to common streaming resolutions and remove duplicates
            val resolutions = supportedSizes
                ?.filter { size ->
                    // Only include standard streaming resolutions
                    (size.width == 3840 && size.height == 2160) || // 4K
                            (size.width == 1920 && size.height == 1080) || // 1080p
                            (size.width == 1280 && size.height == 720) ||  // 720p
                            (size.width == 854 && size.height == 480)      // 480p
                }
                ?.distinctBy { "${it.width}x${it.height}" } // Remove duplicates
                ?.sortedByDescending { it.width } // Sort from highest to lowest
                ?.map { size ->
                    mapOf(
                        "width" to size.width,
                        "height" to size.height,
                        "label" to when {
                            size.width >= 3840 -> "4K"
                            size.width >= 1920 -> "1080p"
                            size.width >= 1280 -> "720p"
                            else -> "480p"
                        }
                    )
                }?.toList() ?: emptyList()

            // Get supported FPS ranges
            val fpsRanges = characteristics.get(
                android.hardware.camera2.CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES
            )

            val supportedFps = fpsRanges
                ?.filter { range -> range.upper >= 30 } // Only 30+ FPS
                ?.distinctBy { it.upper } // Remove duplicates
                ?.sortedByDescending { it.upper } // Sort from highest to lowest
                ?.map { range ->
                    mapOf(
                        "min" to range.lower,
                        "max" to range.upper,
                        "label" to "${range.upper} FPS"
                    )
                }?.toList() ?: emptyList()

            // Get hardware level
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

            // Get max digital zoom
            val maxZoom = characteristics.get(
                android.hardware.camera2.CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM
            ) ?: 1.0f

            val capabilities = mapOf(
                "resolutions" to resolutions,
                "fpsRanges" to supportedFps,
                "hardwareLevel" to hardwareLevelStr,
                "maxDigitalZoom" to maxZoom
            )

            Log.d(TAG, "✅ Camera capabilities:")
            Log.d(TAG, "   Resolutions: ${resolutions.size} options")
            resolutions.forEach { res ->
                Log.d(TAG, "     - ${res["label"]}: ${res["width"]}x${res["height"]}")
            }
            Log.d(TAG, "   FPS ranges: ${supportedFps.size} options")
            supportedFps.forEach { fps ->
                Log.d(TAG, "     - ${fps["label"]}")
            }
            Log.d(TAG, "   Hardware level: $hardwareLevelStr")
            Log.d(TAG, "   Max zoom: ${maxZoom}x")

            result.success(capabilities)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting capabilities: ${e.message}", e)
            result.error("CAPABILITY_ERROR", e.message, null)
        }
    }
    // Add handler method:
    private fun handleTapToFocus(call: MethodCall, result: MethodChannel.Result) {
        try {
            val x = call.argument<Double>("x")?.toFloat() ?: 0f
            val y = call.argument<Double>("y")?.toFloat() ?: 0f
            val width = call.argument<Double>("width")?.toFloat() ?: 1f
            val height = call.argument<Double>("height")?.toFloat() ?: 1f

            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            val focused = service.tapToFocus(x, y, width, height)
            result.success(focused)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error tap to focus: ${e.message}", e)
            result.error("FOCUS_ERROR", e.message, null)
        }
    }
    private fun handleToggleAutoFocus(call: MethodCall, result: MethodChannel.Result) {
        try {
            val enable = call.argument<Boolean>("enable") ?: true
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            if (enable) {
                service.enableAutoFocusManually()
            } else {
                service.disableAutoFocus()
            }
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error toggling auto focus: ${e.message}", e)
            result.error("FOCUS_ERROR", e.message, null)
        }
    }
    /**
     * Start RTMP streaming to YouTube
     */
    private fun handleStartStreaming(call: MethodCall, result: MethodChannel.Result) {
        try {
            Log.d(TAG, "🎬 Starting RTMP streaming...")

            // Get RTMP credentials
            val rtmpUrl = call.argument<String>("rtmpUrl")
            val streamKey = call.argument<String>("streamKey")

            if (rtmpUrl.isNullOrEmpty() || streamKey.isNullOrEmpty()) {
                Log.e(TAG, "❌ Missing RTMP credentials")
                result.error("INVALID_ARGS", "RTMP URL and stream key required", null)
                return
            }

            Log.d(TAG, "   RTMP URL: $rtmpUrl")
            Log.d(TAG, "   Stream Key: ${streamKey.take(10)}...")

            // Get match data (optional - might not be passed)
            @Suppress("UNCHECKED_CAST")
            val matchData = call.argument<Map<String, Any>>("matchData")

            if (matchData != null) {
                Log.d(TAG, "   Match data received: ${matchData.keys}")
            } else {
                Log.w(TAG, "   No match data provided")
            }

            // Get service instance
            val service = StreamingService.INSTANCE
            if (service == null) {
                Log.e(TAG, "❌ Service not running")
                result.error("NO_SERVICE", "Streaming service not running. Start preview first.", null)
                return
            }

            // Check if preview is running
            if (!service.isOnPreview()) {
                Log.e(TAG, "❌ Preview not active")
                result.error("NO_PREVIEW", "Camera preview must be started first", null)
                return
            }

            // Check if already streaming
            if (service.isStreaming()) {
                Log.w(TAG, "⚠️ Already streaming")
                result.error("ALREADY_STREAMING", "Stream is already active", null)
                return
            }

            // Send intent to service to start streaming
            Log.d(TAG, "📤 Sending start stream intent to service...")
            val intent = Intent(context, StreamingService::class.java).apply {
                action = "com.cuex.app.START_STREAM"
                putExtra("rtmp_url", rtmpUrl)
                putExtra("stream_key", streamKey)

                // Only add matchData if it exists
                if (matchData != null) {
                    putExtra("match_data", HashMap(matchData))
                }
            }
            context.startService(intent)

            Log.d(TAG, "✅ Stream start command sent")
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error starting stream: ${e.message}", e)
            result.error("STREAM_ERROR", e.message, null)
        }
    }

    /**
     * Stop RTMP streaming
     */
    private fun handleStopStreaming(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "⏹️ Stopping RTMP streaming...")

            val service = StreamingService.INSTANCE
            if (service == null) {
                Log.w(TAG, "⚠️ Service not running")
                result.success(true) // Not an error, just nothing to stop
                return
            }

            if (!service.isStreaming()) {
                Log.w(TAG, "⚠️ Not streaming")
                result.success(true)
                return
            }

            // Send intent to service to stop streaming
            Log.d(TAG, "📤 Sending stop stream intent to service...")
            val intent = Intent(context, StreamingService::class.java).apply {
                action = "com.cuex.app.STOP_STREAM"
            }
            context.startService(intent)

            Log.d(TAG, "✅ Stream stop command sent")
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error stopping stream: ${e.message}", e)
            result.error("STOP_ERROR", e.message, null)
        }
    }

    /**
     * Update scoreboard with new match data
     */
    private fun handleUpdateScoreboard(call: MethodCall, result: MethodChannel.Result) {
        try {
            Log.d(TAG, "📊 Updating scoreboard...")

            @Suppress("UNCHECKED_CAST")
            val matchData = call.argument<Map<String, Any>>("matchData")
            if (matchData == null) {
                result.error("INVALID_ARGS", "matchData required", null)
                return
            }

            // Send intent to service (like old code)
            val intent = Intent(context, StreamingService::class.java).apply {
                action = StreamingConstants.ACTION_UPDATE_SCOREBOARD
                putExtra(StreamingConstants.EXTRA_MATCH_DATA, HashMap(matchData))
            }
            context.startService(intent)

            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error updating scoreboard: ${e.message}", e)
            result.error("UPDATE_ERROR", e.message, null)
        }
    }

    /**
     * Check if currently streaming
     */
    private fun handleIsStreaming(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            val isStreaming = service?.isStreaming() ?: false
            Log.d(TAG, "❓ isStreaming: $isStreaming")
            result.success(isStreaming)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error checking stream status: ${e.message}", e)
            result.error("STATUS_ERROR", e.message, null)
        }
    }

    /**
     * Set Audio Settings
     */
    private fun handleMuteAudio(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            service.muteAudio()
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error muting audio: ${e.message}", e)
            result.error("MUTE_ERROR", e.message, null)
        }
    }

    private fun handleUnmuteAudio(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            service.unmuteAudio()
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error unmuting audio: ${e.message}", e)
            result.error("UNMUTE_ERROR", e.message, null)
        }
    }

    private fun handleIsAudioMuted(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            val isMuted = service?.isAudioMuted() ?: true
            result.success(isMuted)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error checking audio state: ${e.message}", e)
            result.success(true) // Default to muted
        }
    }
    /**
     * Set camera zoom
     */
    private fun handleSetZoom(call: MethodCall, result: MethodChannel.Result) {
        try {
            val zoom = call.argument<Double>("zoom")?.toFloat() ?: 1.0f

            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            service.setZoom(zoom)
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error setting zoom: ${e.message}", e)
            result.error("ZOOM_ERROR", e.message, null)
        }
    }

    /**
     * Switch camera
     */
    private fun handleSwitchCamera(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            service.switchCamera()
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error switching camera: ${e.message}", e)
            result.error("SWITCH_ERROR", e.message, null)
        }
    }

    /**
     * Get stream health metrics
     */
    private fun handleGetStreamHealth(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            val health = service.getStreamHealth()
            result.success(health)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting stream health: ${e.message}", e)
            result.error("HEALTH_ERROR", e.message, null)
        }
    }

    /**
     * Get current bitrate
     */
    private fun handleGetCurrentBitrate(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.success(0)
                return
            }

            val bitrate = service.getCurrentBitrate()
            result.success(bitrate)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting bitrate: ${e.message}", e)
            result.success(0)
        }
    }

    /**
     * Get average bitrate
     */
    private fun handleGetAverageBitrate(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.success(0)
                return
            }

            val bitrate = service.getAverageBitrate()
            result.success(bitrate)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting average bitrate: ${e.message}", e)
            result.success(0)
        }
    }

    /**
     * Get connection duration
     */
    private fun handleGetConnectionDuration(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.success(0)
                return
            }

            val duration = service.getConnectionDuration()
            result.success(duration)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting duration: ${e.message}", e)
            result.success(0)
        }
    }

    /**
     * Enable/disable auto-reconnect
     */
    private fun handleEnableAutoReconnect(call: MethodCall, result: MethodChannel.Result) {
        try {
            val enabled = call.argument<Boolean>("enabled") ?: true

            val service = StreamingService.INSTANCE
            if (service == null) {
                result.error("NO_SERVICE", "Streaming service not running", null)
                return
            }

            service.setAutoReconnect(enabled)
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error setting auto-reconnect: ${e.message}", e)
            result.error("RECONNECT_ERROR", e.message, null)
        }
    }

    /**
     * Get reconnection status
     */
    private fun handleGetReconnectionStatus(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.success(null)
                return
            }

            val status = service.getReconnectionStatus()
            result.success(status)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting reconnection status: ${e.message}", e)
            result.success(null)
        }
    }

    /**
     * Get connection status
     */
    private fun handleGetConnectionStatus(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            if (service == null) {
                result.success(mapOf(
                    "isStreaming" to false,
                    "isConnected" to false,
                    "connectionState" to "disconnected"
                ))
                return
            }

            val status = service.getConnectionStatus()
            result.success(status)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error getting connection status: ${e.message}", e)
            result.success(null)
        }
    }

    /**
     * Check if preview is active
     */
    private fun handleIsPreviewActive(result: MethodChannel.Result) {
        try {
            val service = StreamingService.INSTANCE
            val isActive = service?.isOnPreview() ?: false
            result.success(isActive)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error checking preview: ${e.message}", e)
            result.success(false)
        }
    }

    /**
     * Release resources
     */
    fun release() {
        Log.d(TAG, "♻️ Releasing StreamingHandler...")

        // Service cleanup is handled by the service itself
        // Just remove callback reference
        StreamingService.INSTANCE?.setCallback(null)

        Log.d(TAG, "✅ Handler released")
    }
}