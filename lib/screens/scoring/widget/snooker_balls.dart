import 'package:flutter/material.dart';

/// Snooker ball selector — 7 colored balls, tap to add points.
/// Row 1: Red (1pt), Yellow (2pt), Green (3pt), Brown (4pt)
/// Row 2: Blue (5pt), Pink (6pt), Black (7pt)
class SnookerBalls extends StatelessWidget {
  final ValueChanged<int> onBallTapped; // returns points value of tapped ball

  const SnookerBalls({super.key, required this.onBallTapped});

  static const _row1 = [
    _BallData('Red', 1, Color(0xFFD32F2F)),
    _BallData('Yellow', 2, Color(0xFFFBC02D)),
    _BallData('Green', 3, Color(0xFF388E3C)),
    _BallData('Brown', 4, Color(0xFF6D4C41)),
  ];

  static const _row2 = [
    _BallData('Blue', 5, Color(0xFF1976D2)),
    _BallData('Pink', 6, Color(0xFFEC407A)),
    _BallData('Black', 7, Color(0xFF212121)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: _row1.map((ball) => Expanded(child: _buildBall(ball))).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ..._row2.map((ball) => Expanded(child: _buildBall(ball))),
            const Expanded(child: SizedBox()), // keeps row2 aligned under row1's 4 columns
          ],
        ),
      ],
    );
  }

  Widget _buildBall(_BallData ball) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => onBallTapped(ball.points),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: ball.color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${ball.points}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _BallData {
  final String name;
  final int points;
  final Color color;

  const _BallData(this.name, this.points, this.color);
}