
// ─────────────────────────────────────────────
// Section Header — title + see all
// ─────────────────────────────────────────────

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/shop/screens/live streaming pedro/presentation/widgets/live_dot.dart';
import '../../../utils/constants/colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.onSeeAll,
    this.isLive = false,
  });

  final String title;
  final VoidCallback onSeeAll;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Live pulse dot
        if (isLive) ...[
          LiveDot(),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TColors.june,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Iconsax.arrow_right_3, size: 12, color: TColors.june),
            ],
          ),
        ),
      ],
    );
  }
}
