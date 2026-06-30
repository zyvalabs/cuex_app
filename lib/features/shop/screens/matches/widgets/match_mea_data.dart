import 'package:flutter/material.dart';

class MatchMetadata extends StatelessWidget {
  const MatchMetadata({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.tournamentName,
    required this.roundName,
    required this.date,
  });

  final String player1Name;
  final String player2Name;
  final String tournamentName;
  final String roundName;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match title
          Text(
            '$player1Name vs $player2Name',
            style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 2),
          ),
          const SizedBox(height: 8),

          // Tournament name
          Text(
            tournamentName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),

          // Round and date
          Row(
            children: [
              Text(
                roundName,
                style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.grey),
              ),
              const Text(' • '),
              Text(
                date,
                style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Usage
