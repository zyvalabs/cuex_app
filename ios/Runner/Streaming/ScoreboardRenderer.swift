import Foundation
import UIKit
import CoreImage
import AVFoundation
import HaishinKit

/// Burns the scoreboard ribbon (and break screen) into the video frames.
/// Colors/layout deliberately match Android's test_ribbon.xml exactly —
/// yellow name bars, white score boxes, blue frame counter, dark break
/// strip with green active-player indicators — so a stream looks
/// identical whether it was broadcast from an Android or iOS device.
final class ScoreboardVideoEffect: VideoEffect {

    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    private var matchData: [String: Any] = [:]
    private var cachedRibbon: CIImage?
    private var cacheKey: String = ""

    private var breakScreenImage: CIImage?
    private var isBreakActive = false

    private let lock = NSLock()

    // MARK: - Colors matching test_ribbon.xml exactly
    private static let colorYellow = UIColor(red: 1.0, green: 0.922, blue: 0.231, alpha: 1)      // #FFEB3B
    private static let colorBlue = UIColor(red: 0.098, green: 0.463, blue: 0.824, alpha: 1)        // #1976D2
    private static let colorGreen = UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 1)       // #10B981
    private static let colorOuterBg = UIColor(white: 0, alpha: 0.5)                                 // #80000000
    private static let colorBottomBg = UIColor(white: 0, alpha: 0.8)                                 // #CC000000
    private static let colorWhite70 = UIColor(white: 1, alpha: 0.7)                                  // #B3FFFFFF
    private static let colorDivider = UIColor(white: 1, alpha: 0.25)                                 // #40FFFFFF

    // MARK: - Public API

    func update(matchData: [String: Any]) {
        lock.lock(); defer { lock.unlock() }
        self.matchData = matchData
        let key = Self.makeKey(matchData)
        if key != cacheKey {
            cacheKey = key
            cachedRibbon = nil
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

        if breakActive, let breakImg {
            let scaled = Self.fit(breakImg, into: canvas)
            return scaled.composited(over: image)
        }

        guard !data.isEmpty else { return image }

        if ribbon == nil {
            let ribbonHeight = canvas.height * 0.0926 // matches SCOREBOARD_SCALE_Y (9.26%)
            let rendered = Self.renderRibbon(data: data, size: CGSize(width: canvas.width, height: ribbonHeight))
            lock.lock(); cachedRibbon = rendered; lock.unlock()
            ribbon = rendered
        }

        guard let ribbon else { return image }

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

    /// Draws the bottom scoreboard ribbon — layout matches test_ribbon.xml:
    /// [top strip: break | match name | break]
    /// [main strip: p1 name | p1 score | frame info | p2 score | p2 name]
    /// [bottom strip: active dot | highest break | divider | highest break | active dot]
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

        let eventName = data["matchName"] as? String ?? "EVENT NAME"
        let roundName = data["roundName"] as? String ?? ""
        let centreText = roundName.isEmpty ? eventName : "\(eventName) · \(roundName)"

        let img = renderer.image { ctx in
            let c = ctx.cgContext
            let w = size.width
            let h = size.height

            // Ratios match XML: top 14dp / main 20dp / bottom 14dp of 48dp total
            let topH = h * (14.0 / 48.0)
            let mainH = h * (20.0 / 48.0)
            let bottomH = h * (14.0 / 48.0)
            let mainY = topH
            let bottomY = topH + mainH

            // Outer semi-transparent black background (matches #80000000)
            c.setFillColor(colorOuterBg.cgColor)
            c.fill(CGRect(x: 0, y: 0, width: w, height: h))

            let smallFont = UIFont.boldSystemFont(ofSize: topH * 0.62)
            let centreFont = UIFont.boldSystemFont(ofSize: topH * 0.60)

            // ---------- TOP STRIP ----------
            let breakAttrs: [NSAttributedString.Key: Any] = [.font: smallFont, .foregroundColor: colorYellow]
            let centreAttrs: [NSAttributedString.Key: Any] = [.font: centreFont, .foregroundColor: colorWhite70]

            "Break: \(p1Break)".draw(at: CGPoint(x: w * 0.012, y: (topH - smallFont.lineHeight) / 2), withAttributes: breakAttrs)

            let centre = centreText as NSString
            let cSize = centre.size(withAttributes: centreAttrs)
            centre.draw(at: CGPoint(x: (w - cSize.width) / 2, y: (topH - cSize.height) / 2), withAttributes: centreAttrs)

            let b2 = "Break: \(p2Break)" as NSString
            let b2Size = b2.size(withAttributes: breakAttrs)
            b2.draw(at: CGPoint(x: w - w * 0.012 - b2Size.width, y: (topH - smallFont.lineHeight) / 2), withAttributes: breakAttrs)

            // ---------- MAIN STRIP ----------
            let scoreW = w * 0.07   // ~52dp equivalent
            let frameW = w * 0.11   // ~80dp equivalent
            let nameW = (w - 2 * scoreW - frameW) / 2

            let nameFont = UIFont.boldSystemFont(ofSize: mainH * 0.42)
            let scoreFont = UIFont.boldSystemFont(ofSize: mainH * 0.50)
            let frameFont = UIFont.boldSystemFont(ofSize: mainH * 0.50)

            // Player 1 name — yellow bg, black text, left-aligned
            c.setFillColor(colorYellow.cgColor)
            c.fill(CGRect(x: 0, y: mainY, width: nameW, height: mainH))
            let n1Attrs: [NSAttributedString.Key: Any] = [.font: nameFont, .foregroundColor: UIColor.black]
            (p1Name as NSString).draw(
                at: CGPoint(x: w * 0.012, y: mainY + (mainH - nameFont.lineHeight) / 2),
                withAttributes: n1Attrs
            )

            // Player 1 score — white bg, black text, centered
            c.setFillColor(UIColor.white.cgColor)
            c.fill(CGRect(x: nameW, y: mainY, width: scoreW, height: mainH))
            let s1 = "\(p1Score)" as NSString
            let s1Attrs: [NSAttributedString.Key: Any] = [.font: scoreFont, .foregroundColor: UIColor.black]
            let s1Size = s1.size(withAttributes: s1Attrs)
            s1.draw(at: CGPoint(x: nameW + (scoreW - s1Size.width) / 2, y: mainY + (mainH - s1Size.height) / 2), withAttributes: s1Attrs)

            // Frame info — blue bg, white text, centered
            c.setFillColor(colorBlue.cgColor)
            c.fill(CGRect(x: nameW + scoreW, y: mainY, width: frameW, height: mainH))
            let frames = "\(p1Frames) (\(total)) \(p2Frames)" as NSString
            let frameAttrs: [NSAttributedString.Key: Any] = [.font: frameFont, .foregroundColor: UIColor.white]
            let frameSize = frames.size(withAttributes: frameAttrs)
            frames.draw(
                at: CGPoint(x: nameW + scoreW + (frameW - frameSize.width) / 2, y: mainY + (mainH - frameSize.height) / 2),
                withAttributes: frameAttrs
            )

            // Player 2 score — white bg, black text, centered
            let p2ScoreX = nameW + scoreW + frameW
            c.setFillColor(UIColor.white.cgColor)
            c.fill(CGRect(x: p2ScoreX, y: mainY, width: scoreW, height: mainH))
            let s2 = "\(p2Score)" as NSString
            let s2Size = s2.size(withAttributes: s1Attrs)
            s2.draw(at: CGPoint(x: p2ScoreX + (scoreW - s2Size.width) / 2, y: mainY + (mainH - s2Size.height) / 2), withAttributes: s1Attrs)

            // Player 2 name — yellow bg, black text, right-aligned
            let p2NameX = p2ScoreX + scoreW
            c.setFillColor(colorYellow.cgColor)
            c.fill(CGRect(x: p2NameX, y: mainY, width: nameW, height: mainH))
            let n2 = p2Name as NSString
            let n2Size = n2.size(withAttributes: n1Attrs)
            n2.draw(at: CGPoint(x: w - w * 0.012 - n2Size.width, y: mainY + (mainH - n2Size.height) / 2), withAttributes: n1Attrs)

            // ---------- BOTTOM STRIP ----------
            c.setFillColor(colorBottomBg.cgColor)
            c.fill(CGRect(x: 0, y: bottomY, width: w, height: bottomH))

            let indicatorW = w * 0.006 // ~3dp equivalent
            if p1Active {
                c.setFillColor(colorGreen.cgColor)
                c.fill(CGRect(x: 0, y: bottomY, width: indicatorW, height: bottomH))
            }
            if p2Active {
                c.setFillColor(colorGreen.cgColor)
                c.fill(CGRect(x: w - indicatorW, y: bottomY, width: indicatorW, height: bottomH))
            }

            let highFont = UIFont.systemFont(ofSize: bottomH * 0.55)
            let highAttrs: [NSAttributedString.Key: Any] = [.font: highFont, .foregroundColor: colorWhite70]

            "Highest Break: \(p1High)".draw(
                at: CGPoint(x: w * 0.012, y: bottomY + (bottomH - highFont.lineHeight) / 2),
                withAttributes: highAttrs
            )

            // Divider line at center
            c.setFillColor(colorDivider.cgColor)
            c.fill(CGRect(x: w / 2 - 0.5, y: bottomY, width: 1, height: bottomH))

            let h2 = "Highest Break: \(p2High)" as NSString
            let h2Size = h2.size(withAttributes: highAttrs)
            h2.draw(at: CGPoint(x: w - w * 0.012 - h2Size.width, y: bottomY + (bottomH - highFont.lineHeight) / 2), withAttributes: highAttrs)
        }

        guard let cg = img.cgImage else { return nil }
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
                .foregroundColor: colorYellow
            ]
            let tSize = title.size(withAttributes: attrs)
            title.draw(
                at: CGPoint(x: (size.width - tSize.width) / 2, y: (size.height - tSize.height) / 2),
                withAttributes: attrs
            )

            let sub = "Match resumes shortly" as NSString
            let sAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.height * 0.035, weight: .regular),
                .foregroundColor: UIColor(white: 0.75, alpha: 1)
            ]
            let sSize = sub.size(withAttributes: sAttrs)
            sub.draw(
                at: CGPoint(x: (size.width - sSize.width) / 2, y: (size.height + tSize.height) / 2 + size.height * 0.02),
                withAttributes: sAttrs
            )
        }
        guard let cg = img.cgImage else { return nil }
        return CIImage(cgImage: cg)
    }
}