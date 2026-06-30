import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

import '../../../controllers/book_table_controller.dart';
import '../../../controllers/slot_controller.dart';
import '../../../controllers/table/slot_mdoel.dart';
class SlotPickerWidget extends StatelessWidget {
  const SlotPickerWidget({
    super.key,
    required this.slotController,
    this.bookController,
  });

  final SlotController slotController;
  final BookTableController? bookController;

  bool _isSelected(SlotModel slot) {
    if (bookController != null) return bookController!.selectedSlotIds.contains(slot.startTime);
    return slotController.selectedSlots.contains(slot.startTime);
  }

  void _onTap(SlotModel slot) {
    if (bookController != null) {
      bookController!.selectSlot(slot.startTime);
    } else {
      slotController.toggleSlot(slot.startTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Slots', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Legend
        Row(
          children: [
            _legendItem(context, TColors.primary, 'Selected'),
            const SizedBox(width: TSizes.spaceBtwItems),
            _legendItem(context, TColors.success, 'Available'),
            const SizedBox(width: TSizes.spaceBtwItems),
            _legendItem(context, Colors.grey, 'Booked'),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Slots
        Obx(() {
          if (slotController.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (slotController.slots.isEmpty) return const Text('No slots available', style: TextStyle(color: Colors.grey));

          return Wrap(
            spacing: TSizes.sm,
            runSpacing: TSizes.sm,
            children: slotController.slots.map((slot) {
              final isSelected = _isSelected(slot);
              final isBooked = slot.status == 'booked';
              final hasDiscount = slot.discountedPrice > 0 && slot.discountedPrice < slot.price;
              final color = isSelected ? TColors.primary : isBooked ? Colors.grey : TColors.success;

              return GestureDetector(
                onTap: isBooked ? null : () => _onTap(slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                    border: Border.all(color: isBooked ? Colors.grey.withOpacity(0.3) : color),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${slot.startTime} - ${slot.endTime}',
                        style: TextStyle(color: isBooked ? Colors.grey : color, fontSize: 12),
                      ),
                      if (hasDiscount) ...[
                        Text(
                          '₹${slot.price.toInt()}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                          ),
                        ),
                        Text(
                          '₹${slot.discountedPrice.toInt()}',
                          style: const TextStyle(color: TColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ] else if (slot.price > 0)
                        Text(
                          '₹${slot.price.toInt()}',
                          style: TextStyle(color: isBooked ? Colors.grey : color, fontSize: 11),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}