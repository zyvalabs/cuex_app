import 'package:cuex_app/features/shop/screens/bookings/widgets/booking_details.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/table/slot_mdoel.dart';
import '../../controllers/table/table_model.dart';
import '../../models/venue_model.dart';
import '../venues/widgets/compact_venue_card.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';


class BookingConfirmScreen extends StatelessWidget {
  const BookingConfirmScreen({
    super.key,
    required this.venue,
    required this.table,
    required this.slots,
    required this.date,
    required this.sportId,
  });

  final VenueModel venue;
  final TableModel table;
  final List<SlotModel> slots;
  final DateTime date;
  final String sportId;

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.put(BookingController());

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Confirm Booking', style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Obx(() => ElevatedButton(
          onPressed: bookingController.isLoading.value
              ? null
              : () => _confirmBooking(context, bookingController),
          child: bookingController.isLoading.value
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
          )
              : const Text('Confirm Booking'),
        )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompactVenueCard(venue: venue),
            const SizedBox(height: TSizes.spaceBtwItems),
            BookingSummaryWidget(table: table, slots: slots, date: date),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Cancellation Policy
            Container(
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.info_circle, color: Colors.orange, size: 18),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: Text(
                      'Free cancellation within 2 hours of booking. Rescheduling also available within the same window.',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context, BookingController controller) async {
    await controller.confirmBooking(
      venueId: venue.id,
      tableId: table.id,
      sportId: sportId,
      slots: slots,
      date: date,
      context: context,
    );
  }
}