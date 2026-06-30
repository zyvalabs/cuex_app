import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/event_controller.dart';

class EventFormatSelector extends StatelessWidget {
  const EventFormatSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final c = EventController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Format', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.sm),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: c.formatOptions.map((format) {
            final isSelected = c.selectedFormat.value == format;
            return GestureDetector(
              onTap: () => c.selectedFormat.value = format,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  format,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        Text('Participant Type', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.sm),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: c.participantTypeOptions.map((type) {
            final isSelected = c.selectedParticipantType.value == type;
            return GestureDetector(
              onTap: () => c.selectedParticipantType.value = type,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
}