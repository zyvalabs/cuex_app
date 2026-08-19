import 'package:flutter/material.dart';

/// Reusable numbered step indicator — pass total steps and current step,
/// use for match creation flow, onboarding, or any multi-step process.
class StepWidget extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 1-indexed
  final Color activeColor;
  final Color inactiveColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final double circleSize;

  const StepWidget({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = Colors.green,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = Colors.black54,
    this.circleSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // connector line between circles
          final leftStep = (index ~/ 2) + 1;
          final isCompleted = leftStep < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? activeColor : inactiveColor,
            ),
          );
        } else {
          final step = (index ~/ 2) + 1;
          final isActive = step <= currentStep;
          return Container(
            width: circleSize,
            height: circleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? activeTextColor : inactiveTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      }),
    );
  }
}