import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../controllers/match_stat_controller.dart';
import '../../../controllers/matches_controller.dart';
import '../../../models/match_model.dart';
import '../../../models/match_stats_model.dart';
class FrameActionButton extends StatelessWidget {
  const FrameActionButton({
    super.key,
    required this.match,
    required this.matchStatsController,
  });

  final MatchModel match;
  final MatchStatsController matchStatsController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentFrame = matchStatsController.currentFrame.value;
      final hasActiveFrame = currentFrame != null && currentFrame.winnerId == null;
      final liveMatch = MatchController.instance.currentMatch.value;
      final status = liveMatch?.matchStatus ?? match.matchStatus;

      return ElevatedButton(
        onPressed: () {
          if (hasActiveFrame) {
            _showEndFrameDialog(context, currentFrame);
          } else {
            _startNewFrame(context, status);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: hasActiveFrame ? Colors.orange : Colors.blue,
        ),
        child: Text(hasActiveFrame ? 'End Frame' : 'Start Frame'),
      );
    });
  }

  void _startNewFrame(BuildContext context, String status) {
    if (status.toLowerCase() != 'live') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Match Not Started'),
          content: const Text('Please start the match before adding frames.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Frame'),
        content: const Text('Are you ready to start the next frame?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final frames = matchStatsController.frames;
                final nextFrameNumber = frames.isEmpty ? 1 : frames.length + 1;

                final newFrame = MatchStatsModel(
                  id: '',
                  matchId: match.id,
                  frameNumber: nextFrameNumber,
                  player1Points: 0,
                  player2Points: 0,
                  player1HighestBreak: 0,
                  player2HighestBreak: 0,
                  player1BallSequence: [],
                  player2BallSequence: [],
                  createdAt: DateTime.now(),
                );

                await matchStatsController.addFrame(newFrame);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Frame $nextFrameNumber started'),
                      backgroundColor: TColors.cranberry,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: TColors.cranberry),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showEndFrameDialog(BuildContext context, MatchStatsModel frame) async {
    if (frame.player1Points == 0 && frame.player2Points == 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot End Frame'),
          content: const Text('Both players have zero points. Play the frame first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (frame.player1Points == frame.player2Points) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tie Not Allowed'),
          content: const Text('Frame cannot end in a tie. Continue playing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final player1 = await UserController.instance.getUserById(match.player1Id!);
    final player2 = await UserController.instance.getUserById(match.player2Id!);

    String winnerId;
    String winnerName;
    String loserName;
    int winnerScore;
    int loserScore;

    if (frame.player1Points > frame.player2Points) {
      winnerId = match.player1Id!;
      winnerName = player1.firstName;
      loserName = player2.firstName;
      winnerScore = frame.player1Points;
      loserScore = frame.player2Points;
    } else {
      winnerId = match.player2Id!;
      winnerName = player2.firstName;
      loserName = player1.firstName;
      winnerScore = frame.player2Points;
      loserScore = frame.player1Points;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Frame ${frame.frameNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏆 $winnerName wins!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('$winnerName: $winnerScore pts', style: const TextStyle(color: Colors.green)),
            Text('$loserName: $loserScore pts', style: const TextStyle(color: Colors.red)),
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
              await matchStatsController.completeFrame(frame.matchId, frame.frameNumber, winnerId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}