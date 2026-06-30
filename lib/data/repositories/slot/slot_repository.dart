import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/controllers/table/slot_mdoel.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class SlotRepository extends GetxController {
  static SlotRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Add single slot
  Future<void> addSlot(SlotModel slot) async {
    try {
      await _db.collection('Slots').add(slot.toJson());
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
  Future<void> updateSlotPricing(String slotId, double price, double discountedPrice) async {
    try {
      await _db.collection('Slots').doc(slotId).update({'price': price, 'discountedPrice': discountedPrice});
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
  /// Fetch slots by tableId and date
  Future<List<SlotModel>> fetchTableSlots(String tableId, DateTime date) async {
    try {
      final start = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
      final end = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59));
      final query = await _db.collection('Slots')
          .where('tableId', isEqualTo: tableId)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();
      return query.docs.map((doc) => SlotModel.fromQueryDocumentSnapshot(doc)).toList();
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

  /// Fetch slots by venueId and date
  Future<List<SlotModel>> fetchVenueSlots(String venueId, DateTime date) async {
    try {
      final start = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
      final end = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59));
      final query = await _db.collection('Slots')
          .where('venueId', isEqualTo: venueId)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();
      return query.docs.map((doc) => SlotModel.fromQueryDocumentSnapshot(doc)).toList();
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

  /// Update slot status
  Future<void> updateSlotStatus(String slotId, String status) async {
    try {
      await _db.collection('Slots').doc(slotId).update({'status': status});
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

  /// Delete slot
  Future<void> deleteSlot(String slotId) async {
    try {
      await _db.collection('Slots').doc(slotId).delete();
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