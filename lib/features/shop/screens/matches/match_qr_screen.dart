import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/constants/colors.dart';
import '../../models/match_model.dart';
import '../live streaming pedro/presentation/screens/LiveStreamingScreen.dart';
import '../live_scroring/live_scoring.dart';

class MatchQRCodeScreen extends StatelessWidget {
  const MatchQRCodeScreen({super.key, required this.match});
  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => orientation == Orientation.portrait
          ? _PortraitLayout(match: match)
          : _LandscapeLayout(match: match),
    );
  }
}

// ─────────────────────────────────────────────
// Portrait Layout
// ─────────────────────────────────────────────

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({required this.match});
  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle ───────────────────────
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _Header(match: match),
          ),
          const SizedBox(height: 20),

          // ── QR Code ──────────────────────
          _QRBox(match: match, size: 220),
          const SizedBox(height: 16),

          // ── Match ID ─────────────────────
          _MatchIdChip(matchId: match.id),
          const SizedBox(height: 16),

          // ── YouTube link ─────────────────
          if (match.youtubeLink != null && match.youtubeLink!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _YouTubeLink(url: match.youtubeLink!),
            ),

          const Spacer(),

          // ── Action buttons ────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: _ActionButtons(match: match),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Landscape Layout
// ─────────────────────────────────────────────

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({required this.match});
  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _Header(match: match),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QRBox(match: match, size: 170),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MatchIdChip(matchId: match.id),
                      if (match.youtubeLink != null &&
                          match.youtubeLink!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _YouTubeLink(url: match.youtubeLink!),
                      ],
                      const SizedBox(height: 16),
                      _ActionButtons(match: match, compact: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.match});
  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: TColors.june.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: TColors.june.withOpacity(0.2)),
          ),
          child: Icon(Iconsax.scan_barcode, size: 17, color: TColors.june),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Match QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Scan to stream or score this match',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// QR Box
// ─────────────────────────────────────────────

class _QRBox extends StatelessWidget {
  const _QRBox({required this.match, this.size = 220});
  final MatchModel match;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TColors.june.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: QrImageView(
        data: match.id,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.white,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Match ID Chip
// ─────────────────────────────────────────────

class _MatchIdChip extends StatelessWidget {
  const _MatchIdChip({required this.matchId});
  final String matchId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: matchId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match ID copied')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.copy, size: 13, color: Colors.white.withOpacity(0.4)),
            const SizedBox(width: 6),
            Text(
              matchId.length > 16
                  ? '${matchId.substring(0, 16)}...'
                  : matchId,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// YouTube Link
// ─────────────────────────────────────────────
class _YouTubeLink extends StatelessWidget {
  const _YouTubeLink({required this.url});
  final String url;

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('YouTube link copied')),
    );
  }

  Future<void> _openLink() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Open in YouTube
        Expanded(
          child: GestureDetector(
            onTap: _openLink,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.video, size: 16, color: Colors.red),
                  SizedBox(width: 7),
                  Text(
                    'Watch on YouTube',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Copy link
        GestureDetector(
          onTap: () => _copyLink(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(
              Iconsax.copy,
              size: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Action Buttons
// ─────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.match, this.compact = false});
  final MatchModel match;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 44.0 : 52.0;

    return Column(
      children: [
        // Start Streaming
        GestureDetector(
          onTap: () => Get.to(() => LiveStreamingScreen(match: match)),
          child: Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.video, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Start Streaming',
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 10),

        // Start Scoring
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Get.to(() => LiveScoringScreen(match: match));
          },
          child: Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: TColors.june,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: TColors.june.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.edit, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Start Scoring',
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}