package com.cuex.app.streaming

import android.util.Log
import com.pedro.library.generic.GenericStream

/**
 * AdaptiveBitrateManager - Automatically adjusts bitrate based on network conditions
 *
 * Monitors connection health and dynamically changes encoder bitrate
 * to maintain stable stream on varying network speeds.
 */
class AdaptiveBitrateManager(
    private val genericStream: GenericStream?,
    private val initialBitrate: Int,
    private val minBitrate: Int = StreamingConstants.MIN_BITRATE,
    private val maxBitrate: Int = StreamingConstants.MAX_BITRATE
) {
    companion object {
        private const val TAG = "AdaptiveBitrateManager"

        // Bitrate adjustment thresholds
        private const val DROP_THRESHOLD = 0.7f // Drop bitrate if < 70% of target
        private const val INCREASE_THRESHOLD = 0.95f // Increase if > 95% stable

        // Adjustment amounts
        private const val DROP_FACTOR = 0.8f // Reduce by 20%
        private const val INCREASE_FACTOR = 1.1f // Increase by 10%
    }

    private var currentTargetBitrate = initialBitrate
    private var stableFrameCount = 0
    private var dropFrameCount = 0

    private val bitrateHistory = mutableListOf<Long>()
    private val maxHistorySize = 10

    /**
     * Update with latest bitrate measurement
     *
     * @param actualBitrate Current measured bitrate (bps)
     * @param droppedFrames Number of frames dropped in last interval
     */
    fun updateMeasurement(actualBitrate: Long, droppedFrames: Int) {
        // Add to history
        bitrateHistory.add(actualBitrate)
        if (bitrateHistory.size > maxHistorySize) {
            bitrateHistory.removeAt(0)
        }

        // Calculate average actual bitrate
        val avgBitrate = if (bitrateHistory.isNotEmpty()) {
            bitrateHistory.average().toLong()
        } else {
            actualBitrate
        }

        val targetBps = currentTargetBitrate.toLong()
        val achievementRatio = avgBitrate.toFloat() / targetBps

        Log.d(TAG, "📊 Bitrate check:")
        Log.d(TAG, "   Target: ${currentTargetBitrate / 1024} kbps")
        Log.d(TAG, "   Actual: ${actualBitrate / 1000} kbps")
        Log.d(TAG, "   Average: ${avgBitrate / 1000} kbps")
        Log.d(TAG, "   Achievement: ${(achievementRatio * 100).toInt()}%")
        Log.d(TAG, "   Dropped frames: $droppedFrames")

        // Decide if adjustment needed
        when {
            // Network struggling - reduce bitrate
            achievementRatio < DROP_THRESHOLD || droppedFrames > 5 -> {
                dropFrameCount++
                stableFrameCount = 0

                if (dropFrameCount >= 2) { // Consistent drops
                    reduceBitrate()
                    dropFrameCount = 0
                }
            }

            // Network stable - potentially increase
            achievementRatio > INCREASE_THRESHOLD && droppedFrames == 0 -> {
                stableFrameCount++
                dropFrameCount = 0

                if (stableFrameCount >= 3) { // Consistently stable
                    increaseBitrate()
                    stableFrameCount = 0
                }
            }

            // Network acceptable - no change
            else -> {
                dropFrameCount = 0
                stableFrameCount = 0
            }
        }
    }

    /**
     * Reduce bitrate due to poor network
     */
    private fun reduceBitrate() {
        val newBitrate = (currentTargetBitrate * DROP_FACTOR).toInt()
            .coerceAtLeast(minBitrate)

        if (newBitrate < currentTargetBitrate) {
            Log.w(TAG, "⬇️ Reducing bitrate: ${currentTargetBitrate / 1024} → ${newBitrate / 1024} kbps")

            currentTargetBitrate = newBitrate
            applyBitrate(newBitrate)
        } else {
            Log.d(TAG, "⚠️ Already at minimum bitrate")
        }
    }

    /**
     * Increase bitrate due to good network
     */
    private fun increaseBitrate() {
        val newBitrate = (currentTargetBitrate * INCREASE_FACTOR).toInt()
            .coerceAtMost(maxBitrate)
            .coerceAtMost(initialBitrate) // Don't exceed initial setting

        if (newBitrate > currentTargetBitrate) {
            Log.i(TAG, "⬆️ Increasing bitrate: ${currentTargetBitrate / 1024} → ${newBitrate / 1024} kbps")

            currentTargetBitrate = newBitrate
            applyBitrate(newBitrate)
        } else {
            Log.d(TAG, "✅ Already at optimal bitrate")
        }
    }

    /**
     * Apply new bitrate to encoder
     */
    private fun applyBitrate(bitrate: Int) {
        try {
            genericStream?.setVideoBitrateOnFly(bitrate)
            Log.d(TAG, "✅ Bitrate updated to ${bitrate / 1024} kbps")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to update bitrate: ${e.message}")
        }
    }

    /**
     * Get current target bitrate
     */
    fun getCurrentBitrate(): Int = currentTargetBitrate

    /**
     * Reset to initial bitrate
     */
    fun reset() {
        Log.d(TAG, "🔄 Resetting to initial bitrate: ${initialBitrate / 1024} kbps")
        currentTargetBitrate = initialBitrate
        stableFrameCount = 0
        dropFrameCount = 0
        bitrateHistory.clear()
        applyBitrate(initialBitrate)
    }
}