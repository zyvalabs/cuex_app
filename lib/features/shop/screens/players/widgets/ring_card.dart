
// --- Ring Stat Card ---
import 'package:cuex_app/features/shop/screens/players/widgets/ring_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RingStatCard extends StatelessWidget {
  const RingStatCard({
    required this.label,
    required this.value,
    required this.displayText,
    required this.color,
    required this.subtitle,
  });

  final String label;
  final double value;
  final String displayText;
  final Color color;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 90,
            height: 90,
            child: CustomPaint(
              painter: RingPainter(progress: value, color: color),
              child: Center(
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}