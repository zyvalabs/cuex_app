import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/table/slot_mdoel.dart';
import '../../../controllers/table/table_model.dart';

import '../../../models/booking_model.dart';

class BookingSummaryWidget extends StatelessWidget {
  const BookingSummaryWidget({
    super.key,
    this.table,
    this.slots,
    this.date,
    this.booking,
  });

  final TableModel? table;
  final List<SlotModel>? slots;
  final DateTime? date;
  final BookingModel? booking;

  double get totalAmount => booking?.totalAmount ?? slots?.fold<double>(0.0, (sum, s) => sum + s.price) ?? 0.0;
  DateTime get displayDate => booking?.date ?? date ?? DateTime.now();
  String get startTime => booking?.startTime ?? slots?.first.startTime ?? '';
  String get endTime => booking?.endTime ?? slots?.last.endTime ?? '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Booking Details', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Date & Table Info
        Container(
          padding: const EdgeInsets.all(TSizes.md),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          ),
          child: Column(
            children: [
              _detailRow(context, 'Date', DateFormat('EEE, dd MMM yyyy').format(displayDate)),
              if (table != null && table!.tableName.isNotEmpty) _detailRow(context, 'Table', table!.tableName),
              if (table != null && table!.tableName.isNotEmpty && table!.tableType != null)
                _detailRow(context, 'Type', table!.tableType!.name.capitalizeFirst!),
              if (startTime.isNotEmpty) _detailRow(context, 'Time', '$startTime - $endTime'),
              if (booking != null) _detailRow(context, 'Status', booking!.status.capitalizeFirst!),
            ],
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Slots
        if (slots != null && slots!.isNotEmpty) ...[
          Text('Selected Slots', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TSizes.spaceBtwItems),
          Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
            child: Column(
              children: [
                ...slots!.map((slot) => Padding(
                  padding: const EdgeInsets.only(bottom: TSizes.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${slot.startTime} - ${slot.endTime}', style: Theme.of(context).textTheme.bodyMedium),
                      Text('₹${slot.price.toInt()}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TColors.primary)),
                    ],
                  ),
                )),
                const Divider(color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleMedium),
                    Text('₹${totalAmount.toInt()}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: TColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],

        /// Total for booking model
        if (booking != null) ...[
          const SizedBox(height: TSizes.spaceBtwItems),
          Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount', style: Theme.of(context).textTheme.titleMedium),
                Text('₹${totalAmount.toInt()}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: TColors.primary)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
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