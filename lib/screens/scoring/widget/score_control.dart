import 'package:flutter/material.dart';

/// Simple +/- score control — used for Pool/Heyball where scoring is just
/// a plain number, not ball-by-ball like Snooker. Dummy UI for now.
class ScoreControl extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ScoreControl({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: 16),
        _ControlButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}