
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/slot_controller.dart';
import '../../bookings/widgets/slot_picker.dart';

/// Slot Management Section
class SlotManagementSection extends StatelessWidget {
  const SlotManagementSection(
      {super.key, required this.slotController, required this.context});

  final SlotController slotController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Slot Management', style: Theme
            .of(context)
            .textTheme
            .headlineSmall),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Select All / Clear / Set Pricing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TextButton(onPressed: slotController.selectAll,
                    child: const Text('Select All')),
                TextButton(onPressed: slotController.clearSelection,
                    child: const Text('Clear')),
              ],
            ),
            Obx(() =>
            slotController.selectedSlots.isNotEmpty
                ? ElevatedButton.icon(
              onPressed: () => _showPricingSheet(context, slotController),
              icon: const Icon(Iconsax.money, size: 16),
              label: const Text('Set Pricing'),
            )
                : const SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Slots Grid
        SlotPickerWidget(slotController: slotController),
      ],
    );
  }

  void _showPricingSheet(BuildContext context, SlotController slotController) {
    final priceController = TextEditingController();
    final discountedPriceController = TextEditingController();

    // Pre-fill if single slot selected
    if (slotController.selectedSlots.length == 1) {
      final slot = slotController.slots.firstWhereOrNull((s) =>
      s.startTime == slotController.selectedSlots.first);
      if (slot != null) {
        priceController.text =
        slot.price > 0 ? slot.price.toInt().toString() : '';
        discountedPriceController.text =
        slot.discountedPrice > 0 ? slot.discountedPrice.toInt().toString() : '';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) =>
          Padding(
            padding: EdgeInsets.only(
              left: TSizes.defaultSpace,
              right: TSizes.defaultSpace,
              top: TSizes.defaultSpace,
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom + TSizes.defaultSpace,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set Pricing', style: Theme
                    .of(context)
                    .textTheme
                    .headlineSmall),
                const SizedBox(height: 4),
                Obx(() =>
                    Text(
                      '${slotController.selectedSlots.length} slots selected',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    )),
                const SizedBox(height: TSizes.spaceBtwItems),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price per Slot',
                      prefixIcon: Icon(Iconsax.money)),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextField(
                  controller: discountedPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Discounted Price per Slot',
                      prefixIcon: Icon(Iconsax.medal)),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      slotController.setPricingForSelected(
                        double.tryParse(priceController.text) ?? 0.0,
                        double.tryParse(discountedPriceController.text) ?? 0.0,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Pricing'),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
              ],
            ),
          ),
    );
  }
}