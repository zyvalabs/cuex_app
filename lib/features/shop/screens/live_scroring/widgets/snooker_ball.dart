import 'package:flutter/material.dart';

class SnookerBall extends StatelessWidget {
  const SnookerBall({
    super.key,
    required this.ballColor,
    this.size = 64,
    this.showPoints = true,
  });

  final String ballColor;
  final double size;
  final bool showPoints;

  Color _getBallColor() {
    switch (ballColor.toLowerCase()) {
      case 'red': return Colors.red;
      case 'yellow': return Colors.yellow;
      case 'green': return Colors.green;
      case 'brown': return Colors.brown;
      case 'blue': return Colors.blue;
      case 'pink': return Colors.pink;
      case 'black': return Colors.black;
      default: return Colors.grey;
    }
  }

  int _getPoints() {
    switch (ballColor.toLowerCase()) {
      case 'red': return 1;
      case 'yellow': return 2;
      case 'green': return 3;
      case 'brown': return 4;
      case 'blue': return 5;
      case 'pink': return 6;
      case 'black': return 7;
      default: return 0;
    }
  }

  Color _getTextColor() {
    if (['red', 'black', 'brown', 'blue'].contains(ballColor.toLowerCase())) {
      return Colors.white;
    }
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBallColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size > 40 ? 2 : 1.5),
        boxShadow: size > 40 ? [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: showPoints
          ? Center(
        child: Text(
          '${_getPoints()}',
          style: TextStyle(
            color: _getTextColor(),
            fontSize: size > 40 ? 22 : size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
    );
  }
}