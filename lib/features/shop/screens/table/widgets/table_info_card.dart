import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/table/table_model.dart';

class TableInfoCard extends StatelessWidget {
  const TableInfoCard({super.key, required this.table});
  final TableModel table;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: Column(
        children: [
          if (table.tableType != null) _infoRow(context, 'Type', table.tableType!.name.capitalizeFirst!),
          if (table.maxPlayers != null) _infoRow(context, 'Max Players', '${table.maxPlayers}'),
          if (table.brand != null && table.brand!.isNotEmpty) _infoRow(context, 'Brand', table.brand!),
          _infoRow(context, 'Status', table.status.capitalizeFirst!),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}