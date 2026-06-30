package com.cuex.app.streaming

import android.util.Log
import com.pedro.common.ConnectChecker
import com.pedro.library.generic.GenericStream

/**
 * StreamConnectionManager - Handles RTMP connection and reconnection
 *
 * Responsibilities:
 * - Start/stop RTMP streaming
 * - Monitor connection status
 * - Auto-reconnect on failure
 * - Track connection attempts
 */
class StreamConnectionManager(
    private val genericStream: GenericStream?,
    private val callback: ConnectChecker?
) : ConnectChecker {

    companion object {
        private const val TAG = "StreamConnectionMgr"
    }

    // ============================================
    // CONNECTION STATE
    // ============================================

    /** Current RTMP endpoint */
    private var currentEndpoint: String? = null

    /** Number of reconnection attempts */
    private var reconnectAttempts = 0

    /** Is auto-reconnect enabled */
    private var autoReconnectEnabled = true

    /** Handler for delayed reconnection */
    private val reconnectHandler = android.os.Handler(android.os.Looper.getMainLooper())

    // ============================================
    // CONNECTION CONTROL
    // ============================================

    /**
     * Start RTMP streaming
     *
     * @param rtmpUrl RTMP server URL
     * @param streamKey YouTube stream key
     * @return true if stream start initiated successfully
     */
    fun startStream(rtmpUrl: String, streamKey: String): Boolean {
        Log.d(TAG, "🚀 startStream() called")
        Log.d(TAG, "   RTMP URL: $rtmpUrl")
        Log.d(TAG, "   Stream Key: ${streamKey.take(10)}...")

        if (genericStream == null) {
            Log.e(TAG, "❌ GenericStream is null")
            return false
        }

        if (genericStream.isStreaming) {
            Log.w(TAG, "⚠️ Already streaming")
            return false
        }

        // Build full endpoint
        currentEndpoint = "$rtmpUrl/$streamKey"
        reconnectAttempts = 0

        Log.d(TAG, "📡 Starting RTMP stream to: $currentEndpoint")
        genericStream.startStream(currentEndpoint!!)

        Log.d(TAG, "✅ Stream start command sent")
        return true
    }

    /**
     * Stop RTMP streaming
     * Disables auto-reconnect
     */
    fun stopStream() {
        Log.d(TAG, "🛑 stopStream() called")

        // Disable auto-reconnect
        autoReconnectEnabled = false
        reconnectHandler.removeCallbacksAndMessages(null)

        if (genericStream?.isStreaming == true) {
            Log.d(TAG, "⏹️ Stopping RTMP stream...")
            genericStream.stopStream()
            Log.d(TAG, "✅ Stream stopped")
        } else {
            Log.w(TAG, "⚠️ Stream not active")
        }

        currentEndpoint = null
        reconnectAttempts = 0
    }

    /**
     * Check if currently streaming
     */
    fun isStreaming(): Boolean {
        val streaming = genericStream?.isStreaming ?: false
        Log.d(TAG, "❓ isStreaming(): $streaming")
        return streaming
    }

    /**
     * Enable/disable auto-reconnect
     */
    fun setAutoReconnect(enabled: Boolean) {
        Log.d(TAG, "🔄 Auto-reconnect: ${if (enabled) "ENABLED" else "DISABLED"}")
        autoReconnectEnabled = enabled
    }

    // ============================================
    // RECONNECTION LOGIC
    // ============================================

    /**
     * Attempt to reconnect to RTMP server
     * Called automatically when connection drops
     */
    private fun attemptReconnect() {
        if (!autoReconnectEnabled) {
            Log.d(TAG, "🚫 Auto-reconnect disabled, not reconnecting")
            return
        }

        if (currentEndpoint == null) {
            Log.e(TAG, "❌ No endpoint to reconnect to")
            return
        }

        if (reconnectAttempts >= StreamingConstants.MAX_RECONNECT_ATTEMPTS) {
            Log.e(TAG, "❌ Max reconnection attempts reached ($reconnectAttempts)")
            callback?.onConnectionFailed("Max reconnection attempts exceeded")
            return
        }

        reconnectAttempts++
        Log.d(TAG, "🔄 Reconnection attempt $reconnectAttempts/${StreamingConstants.MAX_RECONNECT_ATTEMPTS}")

        // Wait before reconnecting
        reconnectHandler.postDelayed({
            Log.d(TAG, "🔄 Reconnecting to: $currentEndpoint")
            genericStream?.startStream(currentEndpoint!!)
        }, StreamingConstants.RECONNECT_DELAY_MS)
    }

    // ============================================
    // ConnectChecker Implementation
    // ============================================

    override fun onConnectionStarted(url: String) {
        Log.d(TAG, "🔵 onConnectionStarted: $url")
        callback?.onConnectionStarted(url)
    }

    override fun onConnectionSuccess() {
        Log.d(TAG, "✅ onConnectionSuccess - Stream is LIVE!")

        // Reset reconnection counter on success
        reconnectAttempts = 0

        callback?.onConnectionSuccess()
    }

    override fun onConnectionFailed(reason: String) {
        Log.e(TAG, "❌ onConnectionFailed: $reason")
        callback?.onConnectionFailed(reason)

        // Attempt reconnection
        Log.d(TAG, "🔄 Connection failed, attempting reconnect...")
        attemptReconnect()
    }

    override fun onNewBitrate(bitrate: Long) {
        Log.d(TAG, "📊 onNewBitrate: ${bitrate / 1000} kbps")
        callback?.onNewBitrate(bitrate)
    }

    override fun onDisconnect() {
        Log.d(TAG, "🔌 onDisconnect - Stream ended")
        callback?.onDisconnect()

        // Attempt reconnection if unexpected disconnect
        if (autoReconnectEnabled) {
            Log.d(TAG, "🔄 Unexpected disconnect, attempting reconnect...")
            attemptReconnect()
        }
    }

    override fun onAuthError() {
        Log.e(TAG, "🔐 onAuthError - Authentication failed")
        callback?.onAuthError()

        // Don't reconnect on auth error (bad credentials)
        autoReconnectEnabled = false
    }

    override fun onAuthSuccess() {
        Log.d(TAG, "✅ onAuthSuccess - Authenticated with server")
        callback?.onAuthSuccess()
    }

    /**
     * Cleanup resources
     */
    fun release() {
        Log.d(TAG, "♻️ Releasing connection manager...")
        autoReconnectEnabled = false
        reconnectHandler.removeCallbacksAndMessages(null)
        currentEndpoint = null
        Log.d(TAG, "✅ Connection manager released")
    }
}