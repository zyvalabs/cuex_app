package com.cuex.app
import com.cuex.app.streaming.CameraPreviewFactory
import com.cuex.app.streaming.StreamingHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var streamingHandler: StreamingHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register camera preview platform view
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("com.cuex.app/camera_preview", CameraPreviewFactory())

        // Create streaming handler
        streamingHandler = StreamingHandler(this)

        // Register method channel
        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.cuex.app/streaming"
        )
        streamingHandler?.setupMethodChannel(methodChannel)

        // Register event channel
        val eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.cuex.app/streaming_events"
        )
        streamingHandler?.setupEventChannel(eventChannel)
    }

    override fun onDestroy() {
        super.onDestroy()
        streamingHandler?.release()
    }
}