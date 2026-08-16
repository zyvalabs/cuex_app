import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var streamingHandler: StreamingHandler?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController
        let messenger = controller.binaryMessenger

        // Register camera preview platform view
        let factory = CameraPreviewFactory(messenger: messenger)
        registrar(forPlugin: "CameraPreview")?
            .register(factory, withId: "com.cuex.app/camera_preview")

        // Register streaming channels
        streamingHandler = StreamingHandler()
        streamingHandler?.setup(messenger: messenger)

        // Keep screen awake
        application.isIdleTimerDisabled = true

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
