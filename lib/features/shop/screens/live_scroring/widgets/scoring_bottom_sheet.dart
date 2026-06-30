import 'package:flutter/material.dart';

import '../../../controllers/match_stat_controller.dart';
import '../../../models/match_model.dart';

import '../../live_scroring/widgets/action_button.dart';
import '../../live_scroring/widgets/ball_grid.dart';
import '../../matches/widgets/frame_action_button.dart';
import '../../matches/widgets/match_action_button.dart';

class ScoringBottomSheet extends StatelessWidget {
  const ScoringBottomSheet({
    super.key,
    required this.match,
    required this.player1Name,
    required this.player2Name,
    required this.sheetController,
    required this.matchStatsController,
  });

  final MatchModel match;
  final String player1Name;
  final String player2Name;
  final DraggableScrollableController sheetController;
  final MatchStatsController matchStatsController;

  static const double minSize = 0.20;
  static const double maxSize = 0.60;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: minSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Handle
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('↑  Swipe up to score', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Ball Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                  child: BallGrid(
                    onBallTapped: (color, value) => matchStatsController.addBall(color, value),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Undo / Reset / Frame
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActionButton(label: 'Undo', onPressed: () => matchStatsController.undoBall()),
                      ActionButton(label: 'Reset', onPressed: () => matchStatsController.resetFrame()),
                      FrameActionButton(match: match, matchStatsController: matchStatsController),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Switch Player
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                  child: ActionButton(
                    label: 'Switch Player',
                    onPressed: () {
                      final playerName = matchStatsController.getCurrentPlayer(match.id) == 'player1'
                          ? player1Name
                          : player2Name;
                      matchStatsController.switchPlayer(matchId: match.id, playerName: playerName);
                    },
                    backgroundColor: Colors.blueGrey,
                    isFullWidth: true,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Match Action
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                  child: MatchActionButton(match: match, matchStatsController: matchStatsController),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}