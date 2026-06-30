import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/match_model.dart';

class MatchInfoWidget extends StatelessWidget {
  const MatchInfoWidget({
    super.key,
    required this.match,
    required this.player1Name,
    required this.player2Name,
    required this.tournamentName,
    required this.roundName,
  });

  final MatchModel match;
  final String player1Name;
  final String player2Name;
  final String tournamentName;
  final String roundName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Match Info Card
        _SectionCard(
          title: 'Match Info',
          icon: Iconsax.info_circle,
          children: [
            _InfoRow(label: 'Tournament', value: tournamentName),
            _InfoRow(label: 'Round', value: roundName),
            _InfoRow(
              label: 'Date',
              value: DateFormat('dd MMM yyyy, hh:mm a')
                  .format(match.scheduledTime),
            ),
            _InfoRow(label: 'Total Frames', value: '${match.totalFrames}'),
            _InfoRow(label: 'Status', value: match.matchStatus.toUpperCase()),
            if (match.venueId != null && match.venueId!.isNotEmpty)
              _InfoRow(label: 'Venue ID', value: match.venueId!),
          ],
        ),
        const SizedBox(height: 16),

        // Players Card
        _SectionCard(
          title: 'Players',
          icon: Iconsax.people,
          children: [
            _InfoRow(label: 'Player 1', value: player1Name),
            _InfoRow(label: 'Player 2', value: player2Name),
            if (match.winnerId != null)
              _InfoRow(
                label: 'Winner',
                value: match.winnerId == match.player1Id
                    ? player1Name
                    : player2Name,
                valueColor: Colors.amber,
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Score Card
        _SectionCard(
          title: 'Frame Score',
          icon: Iconsax.chart,
          children: [
            _InfoRow(
              label: player1Name,
              value: '${match.player1FramesWon} frames',
              valueColor: match.player1FramesWon > match.player2FramesWon
                  ? Colors.green
                  : Colors.white,
            ),
            _InfoRow(
              label: player2Name,
              value: '${match.player2FramesWon} frames',
              valueColor: match.player2FramesWon > match.player1FramesWon
                  ? Colors.green
                  : Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stream Card
        if (match.youtubeLink != null && match.youtubeLink!.isNotEmpty)
          _SectionCard(
            title: 'Live Stream',
            icon: Iconsax.video,
            children: [
              _InfoRow(
                  label: 'Platform',
                  value: match.streamingPlatform ?? 'YouTube'),
              _InfoRow(
                  label: 'Streaming',
                  value: match.isStreaming ? 'Live Now 🔴' : 'Offline'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(match.youtubeLink!);
                    if (await canLaunchUrl(url)) launchUrl(url);
                  },
                  icon: const Icon(Iconsax.export_2, size: 16),
                  label: const Text('Open Stream'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
              const TextStyle(color: Colors.white38, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}