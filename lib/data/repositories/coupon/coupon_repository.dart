import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/coupons_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';


class CouponsRepository extends GetxController {
  static CouponsRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch all coupons for a venue
  Future<List<CouponsModel>> fetchVenueCoupons(String venueId) async {
    try {
      final query = await _db.collection('Coupons').where('venueId', isEqualTo: venueId).get();
      return query.docs.map((doc) => CouponsModel.fromQueryDocumentSnapshot(doc)).toList();
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

  /// Validate coupon by code and venueId
  Future<CouponsModel?> validateCoupon(String code, String venueId) async {
    try {
      final query = await _db.collection('Coupons')
          .where('code', isEqualTo: code.toUpperCase())
          .where('venueId', isEqualTo: venueId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      return CouponsModel.fromQueryDocumentSnapshot(query.docs.first);
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

  /// Create coupon
  Future<void> createCoupon(CouponsModel coupon) async {
    try {
      await _db.collection('Coupons').add(coupon.toJson());
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

  /// Update coupon
  Future<void> updateCoupon(CouponsModel coupon) async {
    try {
      await _db.collection('Coupons').doc(coupon.id).update(coupon.toJson());
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

  /// Delete coupon
  Future<void> deleteCoupon(String couponId) async {
    try {
      await _db.collection('Coupons').doc(couponId).delete();
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

  /// Increment usedCount
  Future<void> incrementUsedCount(String couponId) async {
    try {
      await _db.collection('Coupons').doc(couponId).update({'usedCount': FieldValue.increment(1)});
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

  /// Toggle coupon active status
  Future<void> toggleCouponStatus(String couponId, bool isActive) async {
    try {
      await _db.collection('Coupons').doc(couponId).update({'isActive': isActive});
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