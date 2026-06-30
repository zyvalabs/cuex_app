
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/slot_controller.dart';
import '../../../controllers/table/table_model.dart';
import '../add_table_screen.dart';

/// Action Buttons
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.table, required this.onDelete});
  final TableModel table;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.to(() => AddTableScreen(venueId: table.venueId, table: table)),
            icon: const Icon(Iconsax.edit),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            onPressed: onDelete,
            icon: const Icon(Iconsax.trash),
            label: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}


/// Save Slots Button
class SaveSlotsButton extends StatelessWidget {
  const SaveSlotsButton({super.key, required this.slotController});
  final SlotController slotController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Obx(() => ElevatedButton(
        onPressed: slotController.isLoading.value ? null : () => slotController.saveSlots(context),
        child: slotController.isLoading.value
            ? const CircularProgressIndicator()
            : const Text('Save Slots'),
      )),
    );
  }
}