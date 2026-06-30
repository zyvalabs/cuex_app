import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/promotion_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class PromotionRepository extends GetxController {
  static PromotionRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'Promotions';

  /// Fetch all active promos ordered by order field — for players/partners
  Future<List<PromotionModel>> fetchActivePromos() async {
    try {
      print('🎯 PromotionRepository fetchActivePromos');
      final snapshot = await _db
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('order', descending: false)
          .get();
      print('🎯 PromotionRepository fetchActivePromos — found: ${snapshot.docs.length}');
      return snapshot.docs
          .map((e) => PromotionModel.fromQuerySnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository fetchActivePromos error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch all promos — admin only
  Future<List<PromotionModel>> fetchAllPromos() async {
    try {
      print('🎯 PromotionRepository fetchAllPromos');
      final snapshot = await _db
          .collection(_collection)
          .orderBy('order', descending: false)
          .get();
      print('🎯 PromotionRepository fetchAllPromos — found: ${snapshot.docs.length}');
      return snapshot.docs
          .map((e) => PromotionModel.fromQuerySnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository fetchAllPromos error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch single promo by ID
  Future<PromotionModel> fetchPromoById(String id) async {
    try {
      print('🎯 PromotionRepository fetchPromoById — id: $id');
      final doc = await _db.collection(_collection).doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Promotion $id not found');
      }
      return PromotionModel.fromDocSnapshot(doc);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository fetchPromoById error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Add new promo — admin only
  Future<String> addPromo(PromotionModel promo) async {
    try {
      print('🎯 PromotionRepository addPromo — title: ${promo.title}');
      final doc = await _db.collection(_collection).add(promo.toJson());
      print('🎯 PromotionRepository addPromo — created: ${doc.id}');
      return doc.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository addPromo error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update promo — admin only
  Future<void> updatePromo(PromotionModel promo) async {
    try {
      print('🎯 PromotionRepository updatePromo — id: ${promo.id}');
      await _db
          .collection(_collection)
          .doc(promo.id)
          .update(promo.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository updatePromo error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update single field
  Future<void> updateField(String id, Map<String, dynamic> fields) async {
    try {
      print('🎯 PromotionRepository updateField — id: $id fields: ${fields.keys}');
      await _db.collection(_collection).doc(id).update(fields);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository updateField error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Toggle active status — admin only
  Future<void> toggleActive(String id, bool isActive) async {
    try {
      print('🎯 PromotionRepository toggleActive — id: $id isActive: $isActive');
      await _db.collection(_collection).doc(id).update({
        'isActive': isActive,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository toggleActive error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Increment view count — called when promo is shown
  Future<void> incrementViewCount(String id) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('⚠️ PromotionRepository incrementViewCount error (non-fatal): $e');
    }
  }

  /// Delete promo — admin only
  Future<void> deletePromo(String id) async {
    try {
      print('🎯 PromotionRepository deletePromo — id: $id');
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository deletePromo error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update order for reordering — admin only
  Future<void> updateOrder(String id, int order) async {
    try {
      print('🎯 PromotionRepository updateOrder — id: $id order: $order');
      await _db.collection(_collection).doc(id).update({
        'order': order,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 PromotionRepository updateOrder error: $e');
      throw 'Something went wrong. Please try again';
    }
  }
}