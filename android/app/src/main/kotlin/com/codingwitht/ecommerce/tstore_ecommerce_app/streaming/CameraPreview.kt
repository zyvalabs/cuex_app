// CameraPreview.kt - Complete file with full-screen camera

package com.cuex.app.streaming

import android.content.Context
import android.util.Log
import android.view.SurfaceView
import android.widget.FrameLayout
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class CameraPreviewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return CameraPreview(context, viewId)
    }
}

class CameraPreview(context: Context, id: Int) : PlatformView {

    companion object {
        private const val TAG = "CameraPreview"
        var sharedSurfaceView: SurfaceView? = null
    }

    private val surfaceView: SurfaceView = SurfaceView(context)

    init {
        sharedSurfaceView = surfaceView
        Log.d(TAG, "✅ CameraPreview created, viewId=$id")

        // FULL SCREEN - FILL ENTIRE PARENT
        surfaceView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )

        surfaceView.holder.addCallback(object : android.view.SurfaceHolder.Callback {
            override fun surfaceCreated(holder: android.view.SurfaceHolder) {
                Log.d(TAG, "✅ Surface CREATED")
            }

            override fun surfaceChanged(holder: android.view.SurfaceHolder, format: Int, width: Int, height: Int) {
                Log.d(TAG, "Surface size: ${width}x${height}")
            }

            override fun surfaceDestroyed(holder: android.view.SurfaceHolder) {
                Log.d(TAG, "Surface DESTROYED")
            }
        })
    }

    override fun getView() = surfaceView

    override fun dispose() {
        Log.d(TAG, "CameraPreview disposed")
        sharedSurfaceView = null
    }
}