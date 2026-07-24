import Foundation
import Flutter
import UIKit
import HaishinKit

/// Platform view factory for "com.cuex.app/camera_preview"
/// Mirrors Android's CameraPreviewFactory (SurfaceView).
class CameraPreviewFactory: NSObject, FlutterPlatformViewFactory {

    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return CameraPreview(frame: frame, viewId: viewId)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

/// The actual preview view — MTHKView renders the HaishinKit stream.
class CameraPreview: NSObject, FlutterPlatformView {

    /// Shared reference so the streamer can re-attach after background/foreground.
    static weak var sharedPreviewView: MTHKView?

    private var previewView: MTHKView

    init(frame: CGRect, viewId: Int64) {
        previewView = MTHKView(frame: frame)
        super.init()

        previewView.videoGravity = .resizeAspectFill
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.backgroundColor = .black

        // Bind the stream to this view
        previewView.attachStream(HaishinKitStreamer.shared.stream)

        CameraPreview.sharedPreviewView = previewView

        print("✅ CameraPreview created, viewId=\(viewId)")
    }

    func view() -> UIView {
        return previewView
    }

    deinit {
        print("♻️ CameraPreview disposed")
        previewView.attachStream(nil)
    }
}