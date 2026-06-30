
// booking_controller.dart
import 'package:cuex_app/features/shop/controllers/table/slot_mdoel.dart';
import 'package:cuex_app/features/shop/controllers/table/table_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/popups/loaders.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../data/repositories/booking/booking_repository.dart';
import '../../../data/repositories/slot/slot_repository.dart';
import '../../../data/repositories/table/table_repository.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/booking_model.dart';
import '../screens/bookings/booking_success.dart';


class BookingController extends GetxController {
  static BookingController get instance => Get.find();

  final _repo = Get.put(BookingRepository());
  final isLoading = false.obs;
  final userBookings = <BookingModel>[].obs;
  final venueBookings = <BookingModel>[].obs;
  final tablesMap = <String, TableModel>{}.obs;

  Future<void> confirmBooking({
    required String venueId,
    required String tableId,
    required String sportId,
    required List<SlotModel> slots,
    required DateTime date,
    required BuildContext context,
  }) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.customToast(message: 'No Internet Connection');
        return;
      }

      isLoading.value = true;
      final userId = UserController.instance.user.value.id;
      final slotRepo = Get.put(SlotRepository());

      // Mark all slots as booked
      for (final slot in slots) {
        if (slot.id.isNotEmpty) {
          await slotRepo.updateSlotStatus(slot.id, 'booked');
        }
      }

      final booking = BookingModel(
        id: '',
        userId: userId,
        venueId: venueId,
        tableId: tableId,
        sportId: sportId,
        slotIds: slots.map((s) => s.id).toList(),
        date: date,
        startTime: slots.first.startTime,
        endTime: slots.last.endTime,
        totalAmount: slots.fold(0.0, (sum, s) => sum + s.price),
        status: 'confirmed',
        createdAt: DateTime.now(),
      );

      await _repo.createBooking(booking);

      isLoading.value = false;
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
        );
      }
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
  Future<void> _fetchTablesForBookings(List<BookingModel> bookings) async {
    final tableRepo = Get.put(TableRepository());
    for (final booking in bookings) {
      if (!tablesMap.containsKey(booking.tableId)) {
        final doc = await tableRepo.fetchTableById(booking.tableId);
        tablesMap[booking.tableId] = doc;
      }
    }
  }
  Future<void> fetchBookingsByStatus(String status) async {
    try {
      isLoading.value = true;
      final userId = UserController.instance.user.value.id;
      print('📋 Fetching bookings for userId: $userId status: $status');
      final result = await _repo.fetchBookingsByStatus(userId, status);
      print('📋 Found: ${result.length} bookings');
      userBookings.assignAll(result);
    } catch (e) {
      print('📋 Error: $e');
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllBookings() async {
    try {
      isLoading.value = true;
      userBookings.assignAll(await _repo.fetchAllBookings());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> cancelBooking(BookingModel booking, BuildContext context) async {
    try {
      // 2 hour cancellation window
      final bookingTime = booking.createdAt;
      final now = DateTime.now();
      final diff = now.difference(bookingTime).inHours;

      if (diff >= 2) {
        TLoaders.warningSnackBar(title: 'Cannot Cancel', message: 'Cancellation window of 2 hours has passed');
        return;
      }

      isLoading.value = true;
      await _repo.updateBookingStatus(booking.id, 'cancelled');

      // Free up slots
      final slotRepo = Get.put(SlotRepository());
      for (final slotId in booking.slotIds) {
        if (slotId.isNotEmpty) {
          await slotRepo.updateSlotStatus(slotId, 'available');
        }
      }

      await fetchUserBookings();
      isLoading.value = false;
      TLoaders.successSnackBar(title: 'Cancelled', message: 'Booking cancelled successfully');
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> rescheduleBooking({
    required BookingModel booking,
    required List<SlotModel> newSlots,
    required BuildContext context,
  }) async {
    try {
      // 2 hour reschedule window
      final diff = DateTime.now().difference(booking.createdAt).inHours;
      if (diff >= 2) {
        TLoaders.warningSnackBar(title: 'Cannot Reschedule', message: 'Reschedule window of 2 hours has passed');
        return;
      }

      // Check new slots are available
      final unavailable = newSlots.where((s) => s.status != 'available').toList();
      if (unavailable.isNotEmpty) {
        TLoaders.warningSnackBar(title: 'Slots Unavailable', message: 'Some selected slots are not available');
        return;
      }

      isLoading.value = true;
      final slotRepo = Get.put(SlotRepository());

      // Free old slots
      for (final slotId in booking.slotIds) {
        if (slotId.isNotEmpty) await slotRepo.updateSlotStatus(slotId, 'available');
      }

      // Book new slots
      for (final slot in newSlots) {
        if (slot.id.isNotEmpty) await slotRepo.updateSlotStatus(slot.id, 'booked');
      }

      await _repo.updateBookingSlots(
        booking.id,
        newSlots.map((s) => s.id).toList(),
        newSlots.first.startTime,
        newSlots.last.endTime,
      );

      await fetchUserBookings();
      isLoading.value = false;
      TLoaders.successSnackBar(title: 'Rescheduled', message: 'Booking rescheduled successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> fetchUserBookings() async {
    try {
      isLoading.value = true;
      final userId = UserController.instance.user.value.id;
      userBookings.assignAll(await _repo.fetchUserBookings(userId));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVenueBookings(String venueId) async {
    try {
      isLoading.value = true;
      final result = await _repo.fetchVenueBookings(venueId);
      venueBookings.assignAll(result);
      await _fetchTablesForBookings(result);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _repo.updateBookingStatus(bookingId, status);
      TLoaders.successSnackBar(title: 'Updated', message: 'Booking status updated');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}