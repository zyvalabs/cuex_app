package com.cuex.app.streaming
import android.util.Log

/**
 * StreamHealthMonitor - Monitors stream health and quality
 *
 * Responsibilities:
 * - Track current bitrate
 * - Monitor connection quality
 * - Detect stream issues
 * - Provide health metrics
 */
class StreamHealthMonitor {

    companion object {
        private const val TAG = "StreamHealthMonitor"

        // Health thresholds
        private const val BITRATE_LOW_THRESHOLD = 1000 * 1024L // 1 Mbps
        private const val BITRATE_WARNING_THRESHOLD = 3000 * 1024L // 3 Mbps
    }

    // ============================================
    // HEALTH METRICS
    // ============================================

    /** Current bitrate in bits/second */
    private var currentBitrate: Long = 0

    /** Average bitrate over last 10 samples */
    private val bitrateHistory = mutableListOf<Long>()
    private val maxHistorySize = 10

    /** Connection start time */
    private var connectionStartTime: Long = 0

    /** Total bytes sent */
    private var totalBytesSent: Long = 0

    // ============================================
    // BITRATE TRACKING
    // ============================================

    /**
     * Update current bitrate
     * Called from onNewBitrate callback
     */
    fun updateBitrate(bitrate: Long) {
        currentBitrate = bitrate

        // Add to history
        bitrateHistory.add(bitrate)
        if (bitrateHistory.size > maxHistorySize) {
            bitrateHistory.removeAt(0)
        }

        // Log bitrate with quality indicator
        val quality = getQualityIndicator(bitrate)
        Log.d(TAG, "📊 Bitrate: ${bitrate / 1000} kbps $quality")

        // Check for issues
        checkBitrateHealth(bitrate)
    }

    /**
     * Get current bitrate in kbps
     */
    fun getCurrentBitrate(): Long {
        return currentBitrate / 1000
    }

    /**
     * Get average bitrate in kbps
     */
    fun getAverageBitrate(): Long {
        if (bitrateHistory.isEmpty()) return 0
        return (bitrateHistory.average().toLong()) / 1000
    }

    /**
     * Get quality indicator emoji
     */
    private fun getQualityIndicator(bitrate: Long): String {
        return when {
            bitrate < BITRATE_LOW_THRESHOLD -> "🔴 LOW"
            bitrate < BITRATE_WARNING_THRESHOLD -> "🟡 FAIR"
            else -> "🟢 GOOD"
        }
    }

    // ============================================
    // HEALTH CHECKS
    // ============================================

    /**
     * Check bitrate health and log warnings
     */
    private fun checkBitrateHealth(bitrate: Long) {
        when {
            bitrate < BITRATE_LOW_THRESHOLD -> {
                Log.w(TAG, "⚠️ Low bitrate detected! Stream quality may be poor")
            }
            bitrate < BITRATE_WARNING_THRESHOLD -> {
                Log.w(TAG, "⚠️ Bitrate below optimal level")
            }
        }
    }

    /**
     * Mark connection start
     */
    fun onConnectionStart() {
        connectionStartTime = System.currentTimeMillis()
        bitrateHistory.clear()
        totalBytesSent = 0
        Log.d(TAG, "⏱️ Connection timer started")
    }

    /**
     * Get connection duration in seconds
     */
    fun getConnectionDuration(): Long {
        if (connectionStartTime == 0L) return 0
        return (System.currentTimeMillis() - connectionStartTime) / 1000
    }

    /**
     * Get stream health report
     */
    fun getHealthReport(): Map<String, Any> {
        val duration = getConnectionDuration()
        val avgBitrate = getAverageBitrate()
        val currentBitrateKbps = getCurrentBitrate()

        Log.d(TAG, "📋 Health Report:")
        Log.d(TAG, "   Duration: ${duration}s")
        Log.d(TAG, "   Current Bitrate: $currentBitrateKbps kbps")
        Log.d(TAG, "   Average Bitrate: $avgBitrate kbps")

        return mapOf(
            "duration" to duration,
            "currentBitrate" to currentBitrateKbps,
            "averageBitrate" to avgBitrate,
            "quality" to getQualityIndicator(currentBitrate)
        )
    }

    /**
     * Reset all metrics
     */
    fun reset() {
        Log.d(TAG, "🔄 Resetting health metrics")
        currentBitrate = 0
        bitrateHistory.clear()
        connectionStartTime = 0
        totalBytesSent = 0
    }
}