import Foundation
import Flutter
import UIKit

/// Bridge between Flutter and HaishinKitStreamer.
/// iOS equivalent of Android's StreamingHandler.kt
/// Handles MethodChannel "com.cuex.app/streaming"
/// and EventChannel "com.cuex.app/streaming_events"
class StreamingHandler: NSObject, FlutterStreamHandler {

    private let streamer = HaishinKitStreamer.shared
    private let scoreboard = ScoreboardVideoEffect()

    private var eventSink: FlutterEventSink?
    private var bitrateTimer: Timer?
    private var scoreboardAttached = false

    // MARK: - Setup

    func setup(messenger: FlutterBinaryMessenger) {
        let methodChannel = FlutterMethodChannel(
            name: "com.cuex.app/streaming",
            binaryMessenger: messenger
        )
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }

        let eventChannel = FlutterEventChannel(
            name: "com.cuex.app/streaming_events",
            binaryMessenger: messenger
        )
        eventChannel.setStreamHandler(self)

        streamer.onEvent = { [weak self] event in
            self?.eventSink?(event)
        }

        print("📱 iOS StreamingHandler ready")
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        print("📡 Event channel attached")
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        print("🔴 Event channel detached")
        return nil
    }

    // MARK: - Method dispatch

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        print("📨 iOS method call: \(call.method)")

        switch call.method {

        // ── Preview ──
        case "startPreview":
            guard let matchData = args["matchData"] as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "matchData required", details: nil))
                return
            }
            let width = args["width"] as? Int ?? 1920
            let height = args["height"] as? Int ?? 1080
            let bitrate = args["bitrate"] as? Int ?? (10000 * 1024)

            streamer.prepare(width: width, height: height, bitrate: bitrate)
            attachScoreboardIfNeeded()
            scoreboard.update(matchData: matchData)
            startBitrateTimer()
            result(true)

        case "stopPreview":
            stopBitrateTimer()
            detachScoreboard()
            streamer.stopPreview()
            result(true)

        case "restartPreview":
            streamer.restartPreview()
            attachScoreboardIfNeeded()
            result(true)

        case "isPreviewActive":
            result(streamer.isOnPreview)

        // ── Streaming ──
        case "startStreaming":
            guard let rtmpUrl = args["rtmpUrl"] as? String, !rtmpUrl.isEmpty,
                  let streamKey = args["streamKey"] as? String, !streamKey.isEmpty else {
                result(FlutterError(code: "INVALID_ARGS", message: "RTMP URL and stream key required", details: nil))
                return
            }
            if let matchData = args["matchData"] as? [String: Any] {
                scoreboard.update(matchData: matchData)
            }
            guard streamer.isOnPreview else {
                result(FlutterError(code: "NO_PREVIEW", message: "Camera preview must be started first", details: nil))
                return
            }
            guard !streamer.isStreaming else {
                result(FlutterError(code: "ALREADY_STREAMING", message: "Stream is already active", details: nil))
                return
            }
            let started = streamer.startStream(rtmpUrl: rtmpUrl, streamKey: streamKey)
            result(started)

        case "stopStreaming":
            streamer.stopStream()
            result(true)

        case "isStreaming":
            result(streamer.isStreaming)

        // ── Scoreboard ──
        case "updateScoreboard":
            guard let matchData = args["matchData"] as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "matchData required", details: nil))
                return
            }
            attachScoreboardIfNeeded()
            scoreboard.update(matchData: matchData)
            result(true)

        case "showBreakScreen":
            attachScoreboardIfNeeded()
            scoreboard.showBreakScreen()
            result(true)

        case "hideBreakScreen":
            scoreboard.hideBreakScreen()
            result(true)

        // ── Camera ──
        case "setZoom":
            let zoom = args["zoom"] as? Double ?? 1.0
            streamer.setZoom(Float(zoom))
            result(true)

        case "switchCamera":
            streamer.switchCamera()
            result(true)

        case "setExposure":
            let offset = args["offset"] as? Int ?? 0
            streamer.setExposure(offset)
            result(true)

        case "tapToFocus":
            let x = args["x"] as? Double ?? 0
            let y = args["y"] as? Double ?? 0
            let w = args["width"] as? Double ?? 1
            let h = args["height"] as? Double ?? 1
            result(streamer.tapToFocus(x: CGFloat(x), y: CGFloat(y),
                                       width: CGFloat(w), height: CGFloat(h)))

        case "toggleAutoFocus":
            let enable = args["enable"] as? Bool ?? true
            streamer.toggleAutoFocus(enable)
            result(true)

        case "getCameraCapabilities":
            result(streamer.getCameraCapabilities())

        // ── Audio ──
        case "muteAudio":
            streamer.muteAudio()
            result(true)

        case "unmuteAudio":
            streamer.unmuteAudio()
            result(true)

        case "isAudioMuted":
            result(streamer.isAudioMuted)

        // ── Health / status ──
        case "getStreamHealth":
            result(streamer.getStreamHealth())

        case "getCurrentBitrate":
            result(streamer.getCurrentBitrate())

        case "getAverageBitrate":
            result(streamer.getAverageBitrate())

        case "getConnectionDuration":
            result(streamer.getConnectionDuration())

        case "getConnectionStatus":
            result(streamer.getConnectionStatus())

        case "enableAutoReconnect":
            let enabled = args["enabled"] as? Bool ?? true
            streamer.setAutoReconnect(enabled)
            result(true)

        case "getReconnectionStatus":
            result([
                "isReconnecting": false,
                "attemptCount": 0,
                "maxAttempts": 3
            ])

        default:
            print("⚠️ Method not implemented on iOS: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Scoreboard attach

    private func attachScoreboardIfNeeded() {
        guard !scoreboardAttached else { return }
        _ = streamer.stream.registerVideoEffect(scoreboard)
        scoreboardAttached = true
        print("🎯 Scoreboard effect attached")
    }

    private func detachScoreboard() {
        guard scoreboardAttached else { return }
        _ = streamer.stream.unregisterVideoEffect(scoreboard)
        scoreboardAttached = false
    }

    // MARK: - Bitrate reporting

    private func startBitrateTimer() {
        stopBitrateTimer()
        bitrateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.streamer.sampleBitrate()
        }
    }

    private func stopBitrateTimer() {
        bitrateTimer?.invalidate()
        bitrateTimer = nil
    }

    // MARK: - Cleanup

    func release() {
        stopBitrateTimer()
        detachScoreboard()
        streamer.stopStream()
        streamer.stopPreview()
        eventSink = nil
        print("♻️ iOS StreamingHandler released")
    }
}