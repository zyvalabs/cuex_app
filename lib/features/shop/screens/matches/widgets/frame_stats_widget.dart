import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../controllers/match_stat_controller.dart';
import '../../../models/match_stats_model.dart';

class FrameStatsWidget extends StatelessWidget {
  const FrameStatsWidget({super.key, required this.frame});

  final MatchStatsModel frame;

  bool get _canEdit {
    final role = UserController.instance.user.value.role;
    return role == AppRole.admin || role == AppRole.partner;
  }

  void _showEditDialog(BuildContext context) {
    final p1PointsController =
    TextEditingController(text: frame.player1Points.toString());
    final p2PointsController =
    TextEditingController(text: frame.player2Points.toString());
    final p1BreakController =
    TextEditingController(text: frame.player1HighestBreak.toString());
    final p2BreakController =
    TextEditingController(text: frame.player2HighestBreak.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 16),

            Text(
              'Edit Frame ${frame.frameNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Player 1
            const Text('Player 1',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _EditField(
                      controller: p1PointsController, label: 'Points'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EditField(
                      controller: p1BreakController, label: 'Highest Break'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Player 2
            const Text('Player 2',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _EditField(
                      controller: p2PointsController, label: 'Points'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EditField(
                      controller: p2BreakController, label: 'Highest Break'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updated = MatchStatsModel(
                    id: frame.id,
                    matchId: frame.matchId,
                    frameNumber: frame.frameNumber,
                    player1Points:
                    int.tryParse(p1PointsController.text) ?? frame.player1Points,
                    player2Points:
                    int.tryParse(p2PointsController.text) ?? frame.player2Points,
                    player1HighestBreak:
                    int.tryParse(p1BreakController.text) ?? frame.player1HighestBreak,
                    player2HighestBreak:
                    int.tryParse(p2BreakController.text) ?? frame.player2HighestBreak,
                    player1BallSequence: frame.player1BallSequence,
                    player2BallSequence: frame.player2BallSequence,
                    winnerId: frame.winnerId,
                    completedAt: frame.completedAt,
                    createdAt: frame.createdAt,
                  );

                  await Get.find<MatchStatsController>().updateFrame(updated);
                  if (context.mounted) Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes',
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player1Winning = frame.player1Points > frame.player2Points;

    return GestureDetector(
      onTap: _canEdit ? () => _showEditDialog(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _canEdit ? Colors.white.withOpacity(0.02) : Colors.transparent,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // P1 Break
                _StatCol(
                  label: 'Break',
                  value: frame.player1HighestBreak.toString(),
                ),

                // P1 Points
                _PointsCol(
                  value: frame.player1Points.toString(),
                  highlight: player1Winning,
                ),

                // Center — Frame number + Frames won
                Column(
                  children: [
                    Text(
                      'Frame',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white38),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      frame.frameNumber.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    // Frame winner indicator
                    if (frame.winnerId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green, width: 0.5),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(color: Colors.green, fontSize: 10),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red, width: 0.5),
                        ),
                        child: const Text(
                          'Live',
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                  ],
                ),

                // P2 Points
                _PointsCol(
                  value: frame.player2Points.toString(),
                  highlight: !player1Winning,
                ),

                // P2 Break
                _StatCol(
                  label: 'Break',
                  value: frame.player2HighestBreak.toString(),
                ),
              ],
            ),

            // Edit hint for admin/partner
            if (_canEdit) ...[
              const SizedBox(height: 6),
              const Text(
                'Tap to edit',
                style: TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _PointsCol extends StatelessWidget {
  const _PointsCol({required this.value, required this.highlight});
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Points', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: highlight
              ? BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(4),
          )
              : null,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.apply(
              fontWeightDelta: 2,
              color: highlight ? Colors.black : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}