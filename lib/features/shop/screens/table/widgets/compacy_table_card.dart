import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/table/table_model.dart';

class CompactTableCard extends StatelessWidget {
  const CompactTableCard({super.key, required this.table, this.isSelected = false, this.onTap});

  final TableModel table;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
        decoration: BoxDecoration(
          color: isSelected ? TColors.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          border: Border.all(color: isSelected ? TColors.primary : Colors.transparent),
        ),
        child: Text(
          table.tableName,
          style: TextStyle(color: isSelected ? TColors.primary : Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}