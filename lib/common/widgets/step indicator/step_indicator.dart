import 'package:flutter/material.dart';

/// Reusable 4-step (or any count) indicator.
/// Shows a tick for completed steps, filled circle for current, grey for upcoming.
class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 0-based
  final Color activeColor;
  final Color doneColor;
  final Color inactiveColor;

  const StepIndicator({
    super.key,
    this.totalSteps = 4,
    required this.currentStep,
    this.activeColor = const Color(0xFF0F6E56),
    this.doneColor = const Color(0xFF0F6E56),
    this.inactiveColor = const Color(0xFFD5D5D5),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        // Odd indexes are connector lines
        if (i.isOdd) {
          final stepBefore = (i - 1) ~/ 2;
          final isDone = stepBefore < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone ? doneColor : inactiveColor,
            ),
          );
        }

        final step = i ~/ 2;
        final isDone = step < currentStep;
        final isActive = step == currentStep;

        return _StepCircle(
          label: '${step + 1}',
          isDone: isDone,
          isActive: isActive,
          activeColor: activeColor,
          doneColor: doneColor,
          inactiveColor: inactiveColor,
        );
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isActive;
  final Color activeColor;
  final Color doneColor;
  final Color inactiveColor;

  const _StepCircle({
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.activeColor,
    required this.doneColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isDone
        ? doneColor
        : isActive
        ? activeColor
        : Colors.white;

    final Color border = isDone || isActive ? bg : inactiveColor;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      alignment: Alignment.center,
      child: isDone
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : const Color(0xFF9A9A9A),
        ),
      ),
    );
  }
}