import 'package:flutter/material.dart';
import '../../../core/model/match_model.dart';
import '../../matches/widgets/match_summary_card.dart';


/// Wraps MatchSummaryCard for use inside an event's match list —
/// adds the round name label above the card, and makes it tappable.
class EventMatchListItem extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;

  const EventMatchListItem({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (match.roundName != null && match.roundName!.isNotEmpty) ...[
            Text(
              match.roundName!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey),
            ),
            const SizedBox(height: 6),
          ],
          MatchSummaryCard(
            sport: match.sport,
            matchType: match.matchType,
            format: match.format.isNotEmpty
                ? '${match.format} · Best of ${match.bestOfFrames}'
                : 'Best of ${match.bestOfFrames}',
            playerNames: match.playerNames,
          ),
        ],
      ),
    );
  }
}