import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/sizes.dart';

class MatchDateTimePicker extends StatelessWidget {
  const MatchDateTimePicker({
    super.key,
    required this.dateTime,
    required this.onTap,
  });

  final Rx<DateTime> dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: Icon(Iconsax.calendar, size: 20, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scheduled Time', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy · hh:mm a').format(dateTime.value),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
          ],
        ),
      ),
    ));
  }
}