package com.cuex.app.streaming

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import com.pedro.encoder.input.gl.render.filters.AndroidViewFilterRender
import com.pedro.encoder.input.gl.render.filters.BlackFilterRender
import com.pedro.encoder.utils.gl.TranslateTo
import com.pedro.library.generic.GenericStream
import com.pedro.encoder.input.gl.render.filters.`object`.ImageObjectFilterRender

class ScoreboardManager(
    private val context: Context,
    private val genericStream: GenericStream?
) {

    companion object {
        private const val TAG = "ScoreboardManager"
    }

    private var scoreboardView: View? = null
    private var filter: AndroidViewFilterRender? = null
    private var isBreakActive = false

    fun createScoreboard(matchData: Map<String, Any>): Boolean {
        Log.d(TAG, "📊 createScoreboard() called")

        try {
            val inflater = LayoutInflater.from(context)
            scoreboardView = inflater.inflate(
                context.resources.getIdentifier(
                    StreamingConstants.SCOREBOARD_LAYOUT,
                    "layout",
                    context.packageName
                ),
                null
            )

            if (scoreboardView == null) {
                Log.e(TAG, "❌ Failed to inflate scoreboard layout")
                return false
            }

            Log.d(TAG, "✅ Scoreboard view inflated")

            updateScoreboard(matchData)

            val displayMetrics = context.resources.displayMetrics
            val width = displayMetrics.widthPixels
            val height = (58 * displayMetrics.density).toInt()

            Log.d(TAG, "📐 Measuring scoreboard: ${width}x${height}")

            scoreboardView?.measure(
                View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY)
            )
            scoreboardView?.layout(0, 0, width, height)

            Log.d(TAG, "✅ Scoreboard measured and laid out")

            attachToStream()
            return true

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error creating scoreboard: ${e.message}", e)
            return false
        }
    }

    private fun attachToStream() {
        Log.d(TAG, "🔗 attachToStream() called")

        if (genericStream == null) {
            Log.e(TAG, "❌ GenericStream is null, cannot attach scoreboard")
            return
        }

        if (scoreboardView == null) {
            Log.e(TAG, "❌ Scoreboard view is null, cannot attach")
            return
        }

        try {
            Log.d(TAG, "🔗 Creating AndroidViewFilterRender...")

            filter = AndroidViewFilterRender()
            filter?.view = scoreboardView
            filter?.setScale(100f, StreamingConstants.SCOREBOARD_SCALE_Y)
            filter?.setPosition(TranslateTo.BOTTOM)
            filter?.let { genericStream.getGlInterface().setFilter(it) }

            val pos = filter?.getPosition()
            val scale = filter?.getScale()
            Log.d(TAG, "🎯 Scoreboard attached — Position: X=${pos?.x}, Y=${pos?.y} | Scale: X=${scale?.x}, Y=${scale?.y}")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error attaching scoreboard: ${e.message}", e)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // BREAK SCREEN
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    fun showBreakScreen(): Boolean {
        try {
            // Create break screen bitmap from layout
            val inflater = LayoutInflater.from(context)
            val breakView = inflater.inflate(
                context.resources.getIdentifier("layout_break_screen", "layout", context.packageName),
                null
            )
            val w = 1920
            val h = 1080
            breakView.measure(
                View.MeasureSpec.makeMeasureSpec(w, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(h, View.MeasureSpec.EXACTLY)
            )
            breakView.layout(0, 0, w, h)

            val bitmap = android.graphics.Bitmap.createBitmap(w, h, android.graphics.Bitmap.Config.ARGB_8888)
            val canvas = android.graphics.Canvas(bitmap)
            breakView.draw(canvas)

            // Use ImageObjectFilterRender — camera stays on underneath
            val imageFilter = ImageObjectFilterRender()
            imageFilter.setImage(bitmap)
            imageFilter.setScale(100f, 100f)  // fullscreen
            imageFilter.setPosition(TranslateTo.CENTER)
            genericStream?.getGlInterface()?.setFilter(imageFilter)

            isBreakActive = true
            Log.d(TAG, "✅ Break screen shown via ImageObjectFilterRender")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error: ${e.message}")
            return false
        }
    }

    fun hideBreakScreen(): Boolean {
        Log.d(TAG, "🟢 hideBreakScreen() called")
        Log.d(TAG, "   isBreakActive before: $isBreakActive")
        Log.d(TAG, "   filter null: ${filter == null}")
        Log.d(TAG, "   genericStream null: ${genericStream == null}")

        try {
            if (filter == null) {
                Log.w(TAG, "⚠️ filter is null — clearing all filters instead")
                genericStream?.getGlInterface()?.clearFilters()
            } else {
                Log.d(TAG, "🔄 Restoring scoreboard filter...")
                filter?.let { genericStream?.getGlInterface()?.setFilter(it) }
                Log.d(TAG, "✅ Scoreboard filter restored")
            }

            isBreakActive = false
            Log.d(TAG, "✅ hideBreakScreen() complete — isBreakActive: $isBreakActive")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error hiding break screen: ${e.message}", e)
            return false
        }
    }

    fun isBreakActive(): Boolean = isBreakActive

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // SCOREBOARD UPDATE
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    fun updateScoreboard(matchData: Map<String, Any>) {
        Log.d(TAG, "📊 updateScoreboard() called")

        if (scoreboardView == null) {
            Log.w(TAG, "⚠️ Scoreboard view is null, cannot update")
            return
        }

        try {
            scoreboardView?.apply {

                updateTextView("tv_player1_name", matchData["player1Name"] as? String ?: "PLAYER 1")
                updateTextView("tv_player2_name", matchData["player2Name"] as? String ?: "PLAYER 2")

                updateTextView("tv_player1_score", castInt(matchData["player1Score"]).toString())
                updateTextView("tv_player2_score", castInt(matchData["player2Score"]).toString())

                val eventName = matchData["matchName"] as? String ?: "EVENT NAME"
                val roundName = matchData["roundName"] as? String ?: ""
                val centreText = if (roundName.isNotEmpty()) "$eventName · $roundName" else eventName
                val matchNameView = findViewById<TextView>(
                    context.resources.getIdentifier("tv_match_name", "id", context.packageName)
                )
                matchNameView?.text = centreText
                matchNameView?.isSelected = true

                val p1FramesWon = castInt(matchData["player1FramesWon"])
                val p2FramesWon = castInt(matchData["player2FramesWon"])
                val totalFrames = castInt(matchData["totalFrames"])
                updateTextView("tv_frame_info", "$p1FramesWon ($totalFrames) $p2FramesWon")

                val p1Break = castInt(matchData["player1CurrentBreak"])
                val p2Break = castInt(matchData["player2CurrentBreak"])
                Log.d(TAG, "🔥 breaks: p1=$p1Break p2=$p2Break")
                updateTextView("tv_player1_current_break", "Break: $p1Break")
                updateTextView("tv_player2_current_break", "Break: $p2Break")

                val p1High = castInt(matchData["player1HighestBreak"])
                val p2High = castInt(matchData["player2HighestBreak"])
                updateTextView("tv_player1_high_break", "Highest Break: $p1High")
                updateTextView("tv_player2_high_break", "Highest Break: $p2High")

                val isPlayer1Active = matchData["isPlayer1Active"] as? Boolean ?: false
                val isPlayer2Active = matchData["isPlayer2Active"] as? Boolean ?: false
                updateVisibility("player1_active_indicator", isPlayer1Active)
                updateVisibility("player2_active_indicator", isPlayer2Active)
            }

            scoreboardView?.invalidate()
            scoreboardView?.requestLayout()
            Log.d(TAG, "✅ Scoreboard updated successfully")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error updating scoreboard: ${e.message}", e)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // HELPERS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private fun castInt(value: Any?): Int = when (value) {
        is Int -> value
        is Long -> value.toInt()
        is Double -> value.toInt()
        else -> 0
    }

    private fun View.updateTextView(resourceName: String, text: String) {
        try {
            val resId = context.resources.getIdentifier(resourceName, "id", context.packageName)
            val textView = findViewById<TextView>(resId)
            if (textView != null) {
                textView.text = text
            } else {
                Log.e(TAG, "❌ TextView not found: $resourceName")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error updating $resourceName: ${e.message}")
        }
    }

    private fun View.updateVisibility(resourceName: String, visible: Boolean) {
        try {
            val resId = context.resources.getIdentifier(resourceName, "id", context.packageName)
            findViewById<View>(resId)?.visibility = if (visible) View.VISIBLE else View.GONE
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error updating visibility $resourceName: ${e.message}")
        }
    }

    fun release() {
        Log.d(TAG, "♻️ release() called")
        scoreboardView = null
        filter = null
        isBreakActive = false
        Log.d(TAG, "✅ ScoreboardManager released")
    }
}