import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/sport_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class SportRepository extends GetxController {
  static SportRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'Sports';

  /// Fetch all sports — admin only
  Future<List<SportModel>> fetchAllSports() async {
    try {
      print('🎱 SportRepository fetchAllSports');
      final snapshot = await _db
          .collection(_collection)
          .orderBy('order', descending: false)
          .get();
      print('🎱 SportRepository fetchAllSports — found: ${snapshot.docs.length}');
      return snapshot.docs
          .map((e) => SportModel.fromQuerySnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository fetchAllSports error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch active sports — for players/partners
  Future<List<SportModel>> fetchActiveSports() async {
    try {
      print('🎱 SportRepository fetchActiveSports');
      final snapshot = await _db
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('isTesting', isEqualTo: false)
          .orderBy('order', descending: false)
          .get();
      print('🎱 SportRepository fetchActiveSports — found: ${snapshot.docs.length}');
      return snapshot.docs
          .map((e) => SportModel.fromQuerySnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository fetchActiveSports error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch featured sports — for home screen
  Future<List<SportModel>> fetchFeaturedSports() async {
    try {
      print('🎱 SportRepository fetchFeaturedSports');
      final snapshot = await _db
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .where('isTesting', isEqualTo: false)
          .orderBy('order', descending: false)
          .get();
      return snapshot.docs
          .map((e) => SportModel.fromQuerySnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository fetchFeaturedSports error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Fetch single sport by ID
  Future<SportModel> fetchSportById(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Sport $id not found');
      }
      return SportModel.fromDocSnapshot(doc);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository fetchSportById error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Add new sport — admin only
  Future<String> addSport(SportModel sport) async {
    try {
      print('🎱 SportRepository addSport — name: ${sport.name}');
      final doc = await _db.collection(_collection).add(sport.toJson());
      print('🎱 SportRepository addSport — created: ${doc.id}');
      return doc.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository addSport error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update sport — admin only
  Future<void> updateSport(SportModel sport) async {
    try {
      print('🎱 SportRepository updateSport — id: ${sport.id}');
      await _db.collection(_collection).doc(sport.id).update(sport.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository updateSport error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update single field
  Future<void> updateField(String id, Map<String, dynamic> fields) async {
    try {
      await _db.collection(_collection).doc(id).update(fields);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository updateField error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Toggle active — admin only
  Future<void> toggleActive(String id, bool isActive) async {
    try {
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
      print('🔴 SportRepository toggleActive error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Toggle featured — admin only
  Future<void> toggleFeatured(String id, bool isFeatured) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'isFeatured': isFeatured,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository toggleFeatured error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Toggle testing — admin only
  Future<void> toggleTesting(String id, bool isTesting) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'isTesting': isTesting,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository toggleTesting error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update order — admin only
  Future<void> updateOrder(String id, int order) async {
    try {
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
      print('🔴 SportRepository updateOrder error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Delete sport — admin only
  Future<void> deleteSport(String id) async {
    try {
      print('🎱 SportRepository deleteSport — id: $id');
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 SportRepository deleteSport error: $e');
      throw 'Something went wrong. Please try again';
    }
  }
}