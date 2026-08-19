import 'package:flutter/material.dart';

/// Shows a recap of the created match — sport, format, match type, players.
/// Dummy data for now — will read from MatchCreationController/MatchModel later.
class MatchSummaryCard extends StatelessWidget {
  final String sport;
  final String matchType;
  final String format;
  final List<String> playerNames;

  const MatchSummaryCard({
    super.key,
    required this.sport,
    required this.matchType,
    required this.format,
    required this.playerNames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sport, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('$matchType · $format', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: playerNames
                .map((name) => Chip(
              label: Text(name),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE0E0E0)),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}