import 'package:cuex_app/features/shop/screens/live_scroring/widgets/snooker_ball.dart';
import 'package:flutter/cupertino.dart';

class BallGrid extends StatelessWidget {
  const BallGrid({
    super.key,
    required this.onBallTapped,
  });

  final Function(String ballColor, int ballValue) onBallTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row: Red, Yellow, Green, Brown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => onBallTapped('red', 1),
              child: const SnookerBall(ballColor: 'red', size: 64),
            ),
            GestureDetector(
              onTap: () => onBallTapped('yellow', 2),
              child: const SnookerBall(ballColor: 'yellow', size: 64),
            ),
            GestureDetector(
              onTap: () => onBallTapped('green', 3),
              child: const SnookerBall(ballColor: 'green', size: 64),
            ),
            GestureDetector(
              onTap: () => onBallTapped('brown', 4),
              child: const SnookerBall(ballColor: 'brown', size: 64),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Second row: Blue, Pink, Black
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => onBallTapped('blue', 5),
              child: const SnookerBall(ballColor: 'blue', size: 64),
            ),
            GestureDetector(
              onTap: () => onBallTapped('pink', 6),
              child: const SnookerBall(ballColor: 'pink', size: 64),
            ),
            GestureDetector(
              onTap: () => onBallTapped('black', 7),
              child: const SnookerBall(ballColor: 'black', size: 64),
            ),
          ],
        ),
      ],
    );
  }
}