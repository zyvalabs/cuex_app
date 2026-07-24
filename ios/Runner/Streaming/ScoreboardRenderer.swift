import Foundation
import UIKit
import CoreImage
import AVFoundation
import HaishinKit

/// Burns the scoreboard ribbon (and break screen) into the video frames.
/// iOS equivalent of Android's ScoreboardManager + AndroidViewFilterRender.
final class ScoreboardVideoEffect: VideoEffect {

    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    /// Latest match data pushed from Flutter.
    private var matchData: [String: Any] = [:]

    /// Cached rendered ribbon (regenerated only when data changes).
    private var cachedRibbon: CIImage?
    private var cacheKey: String = ""

    /// Break screen state.
    private var breakScreenImage: CIImage?
    private var isBreakActive = false

    private let lock = NSLock()

    // MARK: - Public API

    func update(matchData: [String: Any]) {
        lock.lock(); defer { lock.unlock() }
        self.matchData = matchData
        let key = Self.makeKey(matchData)
        if key != cacheKey {
            cacheKey = key
            cachedRibbon = nil   // force re-render next frame
        }
    }

    func showBreakScreen() {
        lock.lock(); defer { lock.unlock() }
        isBreakActive = true
        breakScreenImage = Self.renderBreakScreen(size: CGSize(width: 1920, height: 1080))
    }

    func hideBreakScreen() {
        lock.lock(); defer { lock.unlock() }
        isBreakActive = false
        breakScreenImage = nil
    }

    func breakActive() -> Bool {
        lock.lock(); defer { lock.unlock() }
        return isBreakActive
    }

    // MARK: - VideoEffect

    override func execute(_ image: CIImage, info: CMSampleBuffer?) -> CIImage {
        lock.lock()
        let data = matchData
        let breakActive = isBreakActive
        let breakImg = breakScreenImage
        var ribbon = cachedRibbon
        lock.unlock()

        let canvas = image.extent

        // Break screen — full-frame overlay on top of camera
        if breakActive, let breakImg {
            let scaled = Self.fit(breakImg, into: canvas)
            return scaled.composited(over: image)
        }

        guard !data.isEmpty else { return image }

        // Render ribbon if cache is empty
        if ribbon == nil {
            let ribbonHeight = canvas.height * 0.0926   // matches SCOREBOARD_SCALE_Y (9.26%)
            let rendered = Self.renderRibbon(
                data: data,
                size: CGSize(width: canvas.width, height: ribbonHeight)
            )
            lock.lock(); cachedRibbon = rendered; lock.unlock()
            ribbon = rendered
        }

        guard let ribbon else { return image }

        // Position at bottom (matches TranslateTo.BOTTOM on Android)
        let positioned = ribbon.transformed(
            by: CGAffineTransform(translationX: canvas.origin.x, y: canvas.origin.y)
        )

        return positioned.composited(over: image)
    }

    // MARK: - Rendering helpers

    private static func makeKey(_ d: [String: Any]) -> String {
        let keys = [
            "player1Name", "player2Name", "player1Score", "player2Score",
            "player1FramesWon", "player2FramesWon", "totalFrames",
            "player1CurrentBreak", "player2CurrentBreak",
            "player1HighestBreak", "player2HighestBreak",
            "isPlayer1Active", "isPlayer2Active", "matchName", "roundName"
        ]
        return keys.map { "\($0)=\(d[$0] ?? "")" }.joined(separator: "|")
    }

    private static func fit(_ image: CIImage, into rect: CGRect) -> CIImage {
        let sx = rect.width / image.extent.width
        let sy = rect.height / image.extent.height
        return image
            .transformed(by: CGAffineTransform(scaleX: sx, y: sy))
            .transformed(by: CGAffineTransform(translationX: rect.origin.x, y: rect.origin.y))
    }

    private static func int(_ v: Any?) -> Int {
        if let i = v as? Int { return i }
        if let d = v as? Double { return Int(d) }
        if let n = v as? NSNumber { return n.intValue }
        return 0
    }

    /// Draws the bottom scoreboard ribbon.
    private static func renderRibbon(data: [String: Any], size: CGSize) -> CIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let p1Name = (data["player1Name"] as? String ?? "PLAYER 1").uppercased()
        let p2Name = (data["player2Name"] as? String ?? "PLAYER 2").uppercased()
        let p1Score = int(data["player1Score"])
        let p2Score = int(data["player2Score"])
        let p1Frames = int(data["player1FramesWon"])
        let p2Frames = int(data["player2FramesWon"])
        let total = int(data["totalFrames"])
        let p1Break = int(data["player1CurrentBreak"])
        let p2Break = int(data["player2CurrentBreak"])
        let p1High = int(data["player1HighestBreak"])
        let p2High = int(data["player2HighestBreak"])
        let p1Active = data["isPlayer1Active"] as? Bool ?? false
        let p2Active = data["isPlayer2Active"] as? Bool ?? false

        let eventName = data["matchName"] as? String ?? ""
        let roundName = data["roundName"] as? String ?? ""
        let centreText = roundName.isEmpty ? eventName : "\(eventName) · \(roundName)"

        let img = renderer.image { ctx in
            let c = ctx.cgContext
            let h = size.height
            let w = size.width

            // Background
            c.setFillColor(UIColor(white: 0.06, alpha: 0.92).cgColor)
            c.fill(CGRect(x: 0, y: 0, width: w, height: h))

            // Accent line on top
            c.setFillColor(UIColor(red: 0.78, green: 0.66, blue: 0.29, alpha: 1).cgColor)
            c.fill(CGRect(x: 0, y: 0, width: w, height: max(2, h * 0.04)))

            let nameFont = UIFont.systemFont(ofSize: h * 0.30, weight: .semibold)
            let scoreFont = UIFont.systemFont(ofSize: h * 0.44, weight: .bold)
            let smallFont = UIFont.systemFont(ofSize: h * 0.18, weight: .regular)
            let centreFont = UIFont.systemFont(ofSize: h * 0.22, weight: .medium)

            let white: [NSAttributedString.Key: Any] = [
                .font: nameFont, .foregroundColor: UIColor.white
            ]
            let gold: [NSAttributedString.Key: Any] = [
                .font: scoreFont,
                .foregroundColor: UIColor(red: 0.78, green: 0.66, blue: 0.29, alpha: 1)
            ]
            let grey: [NSAttributedString.Key: Any] = [
                .font: smallFont, .foregroundColor: UIColor(white: 0.72, alpha: 1)
            ]
            let centreAttrs: [NSAttributedString.Key: Any] = [
                .font: centreFont, .foregroundColor: UIColor(white: 0.85, alpha: 1)
            ]

            let pad = w * 0.02

            // Active indicator — player 1
            if p1Active {
                c.setFillColor(UIColor(red: 0.06, green: 0.78, blue: 0.42, alpha: 1).cgColor)
                c.fillEllipse(in: CGRect(x: pad * 0.4, y: h * 0.40, width: h * 0.16, height: h * 0.16))
            }

            // Player 1 block
            p1Name.draw(at: CGPoint(x: pad, y: h * 0.14), withAttributes: white)
            "Break: \(p1Break)   Highest: \(p1High)"
                .draw(at: CGPoint(x: pad, y: h * 0.60), withAttributes: grey)

            // Player 1 score
            let s1 = "\(p1Score)" as NSString
            let s1Size = s1.size(withAttributes: gold)
            s1.draw(at: CGPoint(x: w * 0.36 - s1Size.width, y: h * 0.26), withAttributes: gold)

            // Centre — frames + event
            let frames = "\(p1Frames) (\(total)) \(p2Frames)" as NSString
            let fFont = UIFont.systemFont(ofSize: h * 0.30, weight: .bold)
            let fAttrs: [NSAttributedString.Key: Any] = [
                .font: fFont, .foregroundColor: UIColor.white
            ]
            let fSize = frames.size(withAttributes: fAttrs)
            frames.draw(at: CGPoint(x: (w - fSize.width) / 2, y: h * 0.16), withAttributes: fAttrs)

            let centre = centreText as NSString
            let cSize = centre.size(withAttributes: centreAttrs)
            centre.draw(at: CGPoint(x: (w - cSize.width) / 2, y: h * 0.60), withAttributes: centreAttrs)

            // Player 2 score
            let s2 = "\(p2Score)" as NSString
            s2.draw(at: CGPoint(x: w * 0.64, y: h * 0.26), withAttributes: gold)

            // Player 2 block (right aligned)
            let n2 = p2Name as NSString
            let n2Size = n2.size(withAttributes: white)
            n2.draw(at: CGPoint(x: w - pad - n2Size.width, y: h * 0.14), withAttributes: white)

            let b2 = "Break: \(p2Break)   Highest: \(p2High)" as NSString
            let b2Size = b2.size(withAttributes: grey)
            b2.draw(at: CGPoint(x: w - pad - b2Size.width, y: h * 0.60), withAttributes: grey)

            // Active indicator — player 2
            if p2Active {
                c.setFillColor(UIColor(red: 0.06, green: 0.78, blue: 0.42, alpha: 1).cgColor)
                c.fillEllipse(in: CGRect(x: w - pad * 0.4 - h * 0.16, y: h * 0.40,
                                         width: h * 0.16, height: h * 0.16))
            }
        }

        guard let cg = img.cgImage else { return nil }
        // Flip vertically — CoreImage origin is bottom-left
        return CIImage(cgImage: cg)
    }

    /// Full-screen break/interval card.
    private static func renderBreakScreen(size: CGSize) -> CIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let c = ctx.cgContext
            c.setFillColor(UIColor(white: 0.03, alpha: 0.94).cgColor)
            c.fill(CGRect(origin: .zero, size: size))

            let title = "INTERVAL" as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.height * 0.10, weight: .bold),
                .foregroundColor: UIColor(red: 0.78, green: 0.66, blue: 0.29, alpha: 1)
            ]
            let tSize = title.size(withAttributes: attrs)
            title.draw(
                at: CGPoint(x: (size.width - tSize.width) / 2,
                            y: (size.height - tSize.height) / 2),
                withAttributes: attrs
            )

            let sub = "Match resumes shortly" as NSString
            let sAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.height * 0.035, weight: .regular),
                .foregroundColor: UIColor(white: 0.75, alpha: 1)
            ]
            let sSize = sub.size(withAttributes: sAttrs)
            sub.draw(
                at: CGPoint(x: (size.width - sSize.width) / 2,
                            y: (size.height + tSize.height) / 2 + size.height * 0.02),
                withAttributes: sAttrs
            )
        }
        guard let cg = img.cgImage else { return nil }
        return CIImage(cgImage: cg)
    }
}