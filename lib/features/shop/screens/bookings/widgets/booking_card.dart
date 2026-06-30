import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/booking_controller.dart';
import '../../../models/booking_model.dart';
import '../booking_details.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final BookingModel booking;

  Color get _statusColor {
    switch (booking.status) {
      case 'completed': return TColors.success;
      case 'cancelled': return Colors.red;
      default: return TColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {

    final table = BookingController.instance.tablesMap[booking.tableId];

    return GestureDetector(
      onTap: () => Get.to(() => BookingDetailScreen(booking: booking)),
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(table?.tableName ?? booking.tableId, style: Theme.of(context).textTheme.titleMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(TSizes.sm),
                  ),
                  child: Text(booking.status.capitalizeFirst!, style: TextStyle(color: _statusColor, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Iconsax.calendar, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(DateFormat('EEE, dd MMM yyyy').format(booking.date), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Iconsax.clock, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${booking.startTime} - ${booking.endTime}', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
                Text('₹${booking.totalAmount.toInt()}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: TColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}