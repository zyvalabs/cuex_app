import 'package:flutter/material.dart';

import '../../../controllers/match_stat_controller.dart';
import '../../../models/match_model.dart';
import '../../matches/widgets/frame_action_button.dart';
import '../../matches/widgets/match_action_button.dart';
import 'action_button.dart';
import 'ball_grid.dart';


class ScoringControlsWidget extends StatelessWidget {
  const ScoringControlsWidget({
    super.key,
    required this.match,
    required this.matchStatsController,
    required this.player1Name,
    required this.player2Name,
    required this.showControls,
    required this.onToggle,
  });

  final MatchModel match;
  final MatchStatsController matchStatsController;
  final String player1Name;
  final String player2Name;
  final bool showControls;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: showControls ? (isTablet ? 420 : 380) : 50,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          // Toggle bar
          GestureDetector(
            onTap: onToggle,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showControls
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    showControls ? 'Hide Controls' : '↑  Score',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Controls
          if (showControls)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  children: [
                    // Ball Grid
                    BallGrid(
                      onBallTapped: (color, value) =>
                          matchStatsController.addBall(color, value),
                    ),
                    const SizedBox(height: 12),

                    // Undo / Reset / Frame
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ActionButton(
                          label: 'Undo',
                          onPressed: () => matchStatsController.undoBall(),
                        ),
                        ActionButton(
                          label: 'Reset',
                          onPressed: () => matchStatsController.resetFrame(),
                        ),
                        FrameActionButton(
                          match: match,
                          matchStatsController: matchStatsController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Switch Player
                    ActionButton(
                      label: 'Switch Player',
                      onPressed: () {
                        final playerName = matchStatsController
                            .getCurrentPlayer(match.id) ==
                            'player1'
                            ? player1Name
                            : player2Name;
                        matchStatsController.switchPlayer(
                          matchId: match.id,
                          playerName: playerName,
                        );
                      },
                      backgroundColor: Colors.blueGrey,
                      isFullWidth: true,
                      fontSize: isTablet ? 18 : 16,
                    ),
                    const SizedBox(height: 12),

                    // Match Action
                    MatchActionButton(
                      match: match,
                      matchStatsController: matchStatsController,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}