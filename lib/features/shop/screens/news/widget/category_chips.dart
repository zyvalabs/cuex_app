import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

// ─────────────────────────────────────────────
// Category Chips
// ─────────────────────────────────────────────

class NewsCategoryChips extends StatelessWidget {
  const NewsCategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final RxString selected;
  final void Function(String) onSelected;

  static const categories = [
    'All',
    'General',
    'Tournament',
    'Venue Update',
    'Sport News',
    'Announcement',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selected.value == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TColors.june
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isSelected
                        ? TColors.june
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isSelected ? Colors.black : Colors.white54,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }
}