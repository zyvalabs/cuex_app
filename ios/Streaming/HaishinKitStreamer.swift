import Foundation
import AVFoundation
import HaishinKit
import VideoToolbox

/// Core RTMP streamer for iOS — mirrors Android's GenericStream (RootEncoder).
final class HaishinKitStreamer: NSObject {

    static let shared = HaishinKitStreamer()

    private var connection = RTMPConnection()
    private(set) var stream: RTMPStream!

    private(set) var isStreaming = false
    private(set) var isOnPreview = false
    private(set) var isAudioMuted = false

    private var rtmpUrl: String = ""
    private var streamKey: String = ""
    private var currentPosition: AVCaptureDevice.Position = .back

    private var videoWidth: Int = 1920
    private var videoHeight: Int = 1080
    private var videoBitrate: Int = 10000 * 1024
    private var videoFPS: Int = 30

    private var autoReconnectEnabled = true
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 3
    private let reconnectDelay: TimeInterval = 3.0

    private var connectionStartTime: Date?
    private var currentBitrate: Int64 = 0
    private var bitrateHistory: [Int64] = []

    var onEvent: (([String: Any]) -> Void)?

    private override init() {
        super.init()
        stream = RTMPStream(connection: connection)
        connection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        connection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
    }

    // MARK: - Prepare / Preview

    func prepare(width: Int, height: Int, bitrate: Int, fps: Int = 30) {
        videoWidth = width
        videoHeight = height
        videoBitrate = bitrate
        videoFPS = fps

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .videoRecording,
                                    options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("AudioSession error: \(error)")
        }

        stream.frameRate = Float64(fps)
        stream.sessionPreset = .hd1920x1080

        var v = VideoCodecSettings()
        v.videoSize = CGSize(width: width, height: height)
        v.bitRate = bitrate
        v.isHardwareEncoderEnabled = true
        stream.videoSettings = v

        var a = AudioCodecSettings()
        a.bitRate = 128 * 1000
        stream.audioSettings = a

        attachCameraDevice()
        attachAudioDevice()

        isOnPreview = true
        print("iOS stream prepared \(width)x\(height) @ \(bitrate / 1024) kbps")
    }

    private func attachCameraDevice() {
        let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: currentPosition
        )
        stream.attachCamera(camera) { _, error in
            if let error { print("attachCamera error: \(error)") }
        }
    }

    private func attachAudioDevice() {
        let mic = AVCaptureDevice.default(for: .audio)
        stream.attachAudio(mic) { _, error in
            if let error { print("attachAudio error: \(error)") }
        }
    }

    func stopPreview() {
        stream.attachCamera(nil)
        stream.attachAudio(nil)
        isOnPreview = false
    }

    func restartPreview() {
        stream.attachCamera(nil)
        attachCameraDevice()
        isOnPreview = true
    }

    // MARK: - Streaming

    func startStream(rtmpUrl: String, streamKey: String) -> Bool {
        guard isOnPreview else { return false }
        guard !isStreaming else { return false }

        self.rtmpUrl = rtmpUrl
        self.streamKey = streamKey
        autoReconnectEnabled = true
        reconnectAttempts = 0

        sendEvent(["type": "connectionStarted", "url": rtmpUrl])
        connection.connect(rtmpUrl)
        return true
    }

    func stopStream() {
        autoReconnectEnabled = false
        stream.close()
        connection.close()
        isStreaming = false
        connectionStartTime = nil
        bitrateHistory.removeAll()
        sendEvent(["type": "disconnected"])
    }

    // MARK: - Camera controls

    private func currentDevice() -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition)
    }

    func setZoom(_ zoom: Float) {
        guard let device = currentDevice() else { return }
        do {
            try device.lockForConfiguration()
            let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 5.0)
            device.videoZoomFactor = CGFloat(max(1.0, min(Double(zoom), Double(maxZoom))))
            device.unlockForConfiguration()
        } catch { print("setZoom: \(error)") }
    }

    func switchCamera() {
        currentPosition = (currentPosition == .back) ? .front : .back
        attachCameraDevice()
    }

    func setExposure(_ offset: Int) {
        guard let device = currentDevice() else { return }
        do {
            try device.lockForConfiguration()
            let bias = max(device.minExposureTargetBias,
                           min(device.maxExposureTargetBias, Float(offset)))
            device.setExposureTargetBias(bias, completionHandler: nil)
            device.unlockForConfiguration()
        } catch { print("setExposure: \(error)") }
    }

    func tapToFocus(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> Bool {
        guard let device = currentDevice() else { return false }
        let point = CGPoint(x: x / max(width, 1), y: y / max(height, 1))
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
            return true
        } catch { return false }
    }

    func toggleAutoFocus(_ enable: Bool) {
        guard let device = currentDevice() else { return }
        do {
            try device.lockForConfiguration()
            if enable, device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            } else if device.isFocusModeSupported(.locked) {
                device.focusMode = .locked
            }
            device.unlockForConfiguration()
        } catch { print("toggleAutoFocus: \(error)") }
    }

    // MARK: - Audio

    func muteAudio() {
        stream.attachAudio(nil)
        isAudioMuted = true
    }

    func unmuteAudio() {
        attachAudioDevice()
        isAudioMuted = false
    }

    // MARK: - Health

    func getConnectionDuration() -> Int {
        guard let start = connectionStartTime else { return 0 }
        return Int(Date().timeIntervalSince(start))
    }

    func getCurrentBitrate() -> Int { Int(currentBitrate / 1000) }

    func getAverageBitrate() -> Int {
        guard !bitrateHistory.isEmpty else { return 0 }
        return Int(bitrateHistory.reduce(0, +) / Int64(bitrateHistory.count) / 1000)
    }

    private func qualityIndicator() -> String {
        let kbps = currentBitrate / 1000
        if kbps < 1000 { return "LOW" }
        if kbps < 3000 { return "FAIR" }
        return "GOOD"
    }

    func getStreamHealth() -> [String: Any] {
        [
            "duration": getConnectionDuration(),
            "currentBitrate": getCurrentBitrate(),
            "averageBitrate": getAverageBitrate(),
            "quality": qualityIndicator()
        ]
    }

    func setAutoReconnect(_ enabled: Bool) { autoReconnectEnabled = enabled }

    func getConnectionStatus() -> [String: Any] {
        [
            "isStreaming": isStreaming,
            "isConnected": isStreaming,
            "connectionState": isStreaming ? "connected" : "disconnected",
            "streamHealth": getStreamHealth()
        ]
    }

    func getCameraCapabilities() -> [String: Any] {
        var resolutions: [[String: Any]] = []
        let candidates: [(Int, Int, String)] = [
            (3840, 2160, "4K"), (1920, 1080, "1080p"),
            (1280, 720, "720p"), (854, 480, "480p")
        ]
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .back
        ) else {
            return ["resolutions": [], "fpsRanges": [],
                    "hardwareLevel": "Unknown", "maxDigitalZoom": 1.0]
        }
        for (w, h, label) in candidates {
            let supported = device.formats.contains { fmt in
                let d = CMVideoFormatDescriptionGetDimensions(fmt.formatDescription)
                return Int(d.width) >= w && Int(d.height) >= h
            }
            if supported {
                resolutions.append(["width": w, "height": h, "label": label])
            }
        }
        let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 5.0)
        return [
            "resolutions": resolutions,
            "fpsRanges": [["min": 24, "max": 30, "label": "30 FPS"]],
            "hardwareLevel": "Full",
            "maxDigitalZoom": Float(maxZoom)
        ]
    }

    // MARK: - RTMP callbacks

    @objc private func rtmpStatusHandler(_ notification: Notification) {
        let e = Event.from(notification)
        guard let data = e.data as? ASObject,
              let code = data["code"] as? String else { return }

        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            reconnectAttempts = 0
            connectionStartTime = Date()
            isStreaming = true
            stream.publish(streamKey)
            sendEvent(["type": "authSuccess"])
            sendEvent(["type": "connectionSuccess"])

        case RTMPConnection.Code.connectFailed.rawValue:
            isStreaming = false
            sendEvent(["type": "connectionFailed", "reason": code])
            attemptReconnect()

        case RTMPConnection.Code.connectClosed.rawValue:
            isStreaming = false
            sendEvent(["type": "disconnected"])
            attemptReconnect()

        default:
            break
        }
    }

    @objc private func rtmpErrorHandler(_ notification: Notification) {
        isStreaming = false
        sendEvent(["type": "connectionFailed", "reason": "IO error"])
        attemptReconnect()
    }

    private func attemptReconnect() {
        guard autoReconnectEnabled, !rtmpUrl.isEmpty else { return }
        guard reconnectAttempts < maxReconnectAttempts else {
            sendEvent(["type": "connectionFailed",
                       "reason": "Max reconnection attempts exceeded"])
            return
        }
        reconnectAttempts += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            guard let self else { return }
            self.connection.connect(self.rtmpUrl)
        }
    }

    func sampleBitrate() {
        let bps = Int64(stream.videoSettings.bitRate)
        currentBitrate = bps
        bitrateHistory.append(bps)
        if bitrateHistory.count > 10 { bitrateHistory.removeFirst() }
        if isStreaming {
            sendEvent(["type": "bitrateChanged", "bitrate": Int(bps)])
        }
    }

    private func sendEvent(_ payload: [String: Any]) {
        var p = payload
        p["timestamp"] = Int(Date().timeIntervalSince1970 * 1000)
        DispatchQueue.main.async { [weak self] in self?.onEvent?(p) }
    }
}