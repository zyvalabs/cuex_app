import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../personalization/controllers/user_controller.dart';
import '../../../controllers/match_stat_controller.dart';
import '../../../controllers/matches_controller.dart';
import '../../../models/match_model.dart';
import '../../live_scroring/widgets/action_button.dart';


class MatchActionButton extends StatelessWidget {
  const MatchActionButton({
    super.key,
    required this.match,
    required this.matchStatsController,
  });

  final MatchModel match;
  final MatchStatsController matchStatsController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentMatch = MatchController.instance.currentMatch.value;
      final isLive = currentMatch?.matchStatus == 'live';

      return ActionButton(
        label: isLive ? 'End Match' : 'Start Match',
        onPressed: () {
          if (isLive) {
            _showEndMatchDialog(context);
          } else {
            _showStartMatchDialog(context);
          }
        },
        backgroundColor: isLive ? Colors.red : Colors.green,
        isFullWidth: true,
        fontSize: 18,
      );
    });
  }

  void _showStartMatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start Match'),
          content: const Text('Ready to start the match?'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await MatchController.instance.startMatch(match.id);
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  void _showEndMatchDialog(BuildContext context) async {
    // Fetch actual player names
    final player1 = await UserController.instance.getUserById(match.player1Id!);
    final player2 = await UserController.instance.getUserById(match.player2Id!);

    final frames = matchStatsController.frames;
    final p1Wins = frames.where((f) => f.winnerId == match.player1Id).length;
    final p2Wins = frames.where((f) => f.winnerId == match.player2Id).length;

    final winnerId = p1Wins > p2Wins ? match.player1Id! : match.player2Id!;
    final winnerName = p1Wins > p2Wins ? player1.firstName : player2.firstName;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Match'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to end this match?'),
            const SizedBox(height: 12),
            Text(
              '🏆 $winnerName wins!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('${player1.firstName}: $p1Wins frames'),
            Text('${player2.firstName}: $p2Wins frames'),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await MatchController.instance.completeMatch(match.id, winnerId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('End Match'),
          ),
        ],
      ),
    );
  }
}