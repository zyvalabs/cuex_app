// booking_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/booking_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class BookingRepository extends GetxController {
  static BookingRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createBooking(BookingModel booking) async {
    try {
      await _db.collection('Bookings').add(booking.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  Future<List<BookingModel>> fetchAllBookings() async {
    try {
      final query = await _db.collection('Bookings').orderBy('createdAt', descending: true).get();
      return query.docs.map((doc) => BookingModel.fromQueryDocumentSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  Future<List<BookingModel>> fetchUserBookings(String userId) async {
    try {
      final query = await _db.collection('Bookings').where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).get();
      return query.docs.map((doc) => BookingModel.fromQueryDocumentSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<BookingModel>> fetchVenueBookings(String venueId) async {

    try {
      final query = await _db.collection('Bookings').where('venueId', isEqualTo: venueId).orderBy('createdAt', descending: true).get();
      print('📋 Found: ${query.docs.length} bookings');
      return query.docs.map((doc) => BookingModel.fromQueryDocumentSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<BookingModel>> fetchBookingsByDate(String venueId, DateTime date) async {
    try {
      final start = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
      final end = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59));
      final query = await _db.collection('Bookings')
          .where('venueId', isEqualTo: venueId)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();
      return query.docs.map((doc) => BookingModel.fromQueryDocumentSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<BookingModel>> fetchBookingsByStatus(String userId, String status) async {
    try {
      final query = await _db.collection('Bookings')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .get();
      return query.docs.map((doc) => BookingModel.fromQueryDocumentSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _db.collection('Bookings').doc(bookingId).update({'status': status});
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> updateBookingSlots(String bookingId, List<String> slotIds, String startTime, String endTime) async {
    try {
      await _db.collection('Bookings').doc(bookingId).update({
        'slotIds': slotIds,
        'startTime': startTime,
        'endTime': endTime,
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
