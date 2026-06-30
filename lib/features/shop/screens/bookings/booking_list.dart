import 'package:cuex_app/features/shop/screens/bookings/widgets/booking_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/venue_controller.dart';
class BookingsList extends StatelessWidget {
  const BookingsList({super.key, required this.status, required this.controller});

  final String status;
  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    final role = UserController.instance.user.value.role;

    if (role == AppRole.partner) {
      controller.fetchVenueBookings(VenueController.instance.venue.value.id);
    } else if (role == AppRole.admin) {
      controller.fetchAllBookings();
    } else {
      controller.fetchBookingsByStatus(status);
    }

    return Obx(() {
      final allBookings = (role == AppRole.partner || role == AppRole.admin)
          ? controller.venueBookings
          : controller.userBookings;

      final filtered = allBookings.where((b) => b.status == status).toList();

      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (filtered.isEmpty) return Center(child: Text('No $status bookings', style: const TextStyle(color: Colors.grey)));

      return ListView.separated(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
        itemBuilder: (_, index) => BookingCard(booking: filtered[index]),
      );
    });
  }
}