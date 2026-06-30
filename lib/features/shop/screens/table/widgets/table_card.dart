import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/table/table_model.dart';

class TableCard extends StatelessWidget {
  const TableCard({super.key, required this.table, this.onTap});

  final TableModel table;
  final VoidCallback? onTap;

  Color get _statusColor {
    switch (table.status) {
      case 'booked': return Colors.red;
      case 'maintenance': return Colors.orange;
      default: return TColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.grid_1, color: TColors.primary, size: 32),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(table.tableName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  if (table.tableType != null || (table.brand != null && table.brand!.isNotEmpty))
                    Row(
                      children: [
                        if (table.tableType != null)
                          Text(table.tableType!.name.capitalizeFirst!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
                        if (table.tableType != null && table.brand != null && table.brand!.isNotEmpty)
                          const Text(' · ', style: TextStyle(color: Colors.grey)),
                        if (table.brand != null && table.brand!.isNotEmpty)
                          Text(table.brand!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  if (table.maxPlayers != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Iconsax.people, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Max ${table.maxPlayers} players', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(TSizes.sm),
              ),
              child: Text(
                table.status.capitalizeFirst!,
                style: TextStyle(color: _statusColor, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}