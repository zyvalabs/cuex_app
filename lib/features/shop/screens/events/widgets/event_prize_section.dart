import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/event_controller.dart';

class EventPrizeSection extends StatelessWidget {
  const EventPrizeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = EventController.instance;
    return Column(
      children: [
        TextFormField(
          controller: c.entryFeeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Entry Fee (Optional)',
            hintText: '0.00',
            prefixIcon: Icon(Iconsax.money, size: 18),
            prefixText: '₹ ',
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        TextFormField(
          controller: c.prizePoolController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Prize Pool (Optional)',
            hintText: '0.00',
            prefixIcon: Icon(Iconsax.level, size: 18),
            prefixText: '₹ ',
          ),
        ),
      ],
    );
  }
}