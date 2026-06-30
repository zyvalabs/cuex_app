import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';

class DotsIndicator extends StatelessWidget {
  const DotsIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final double current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current.round();
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? TColors.primary : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}