import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/sizes.dart';

class EventDatePicker extends StatelessWidget {
  const EventDatePicker({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final Rxn<DateTime> date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        ),
        child: Row(
          children: [
            Icon(Iconsax.calendar, size: 18, color: date.value != null ? Theme.of(context).primaryColor : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                date.value != null ? DateFormat('dd MMM yyyy').format(date.value!) : label,
                style: TextStyle(color: date.value != null ? null : Colors.grey, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    ));
  }
}