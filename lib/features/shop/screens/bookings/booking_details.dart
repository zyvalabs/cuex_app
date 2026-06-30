import 'package:cuex_app/features/shop/screens/bookings/widgets/booking_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../../personalization/screens/profile/widgets/user_info_tile.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/table/table_model.dart';
import '../../controllers/venue_controller.dart';
import '../../models/booking_model.dart';
import '../../models/venue_model.dart';
import '../venues/widgets/compact_venue_card.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.put(BookingController());

    final role = UserController.instance.user.value.role;
    final isPartnerOrAdmin = role == AppRole.partner || role == AppRole.admin;
    final canCancel = DateTime.now().difference(booking.createdAt).inHours < 2 && booking.status == 'confirmed';

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Booking Details', style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Venue Card - player only
            if (!isPartnerOrAdmin) ...[
              CompactVenueCard(venue: Get.isRegistered<VenueController>() ? VenueController.instance.venue.value : VenueModel.empty()),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],

            /// User Info - partner/admin only
            if (isPartnerOrAdmin) ...[
              Text('Player Info', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.spaceBtwItems),
              UserInfoTile(userId: booking.userId),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],

            /// Booking Summary
            BookingSummaryWidget(
              table: TableModel.empty(),
              slots: [],
              date: booking.date,
              booking: booking,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Actions
            /// Partner/Admin actions
            if (isPartnerOrAdmin && booking.status == 'confirmed') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => bookingController.updateBookingStatus(booking.id, 'completed'),
                  icon: const Icon(Iconsax.tick_circle),
                  label: const Text('Mark Completed'),
                ),
              ),
            ],

            /// Player actions only
            if (!isPartnerOrAdmin && canCancel) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  onPressed: () => bookingController.cancelBooking(booking, context),
                  icon: const Icon(Iconsax.close_circle),
                  label: const Text('Cancel Booking'),
                ),
              ),
            ],

            if (!isPartnerOrAdmin && canCancel) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  onPressed: () => bookingController.cancelBooking(booking, context),
                  icon: const Icon(Iconsax.close_circle),
                  label: const Text('Cancel Booking'),
                ),
              ),
            ],

            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}