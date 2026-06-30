import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/event_draw_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class EventDrawRepository extends GetxController {
  static EventDrawRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'EventDraws';

  /// Fetch all draws for event by type
  Future<List<EventDrawModel>> fetchByEventAndType(
      String eventId, String type) async {
    try {
      print('📋 fetchByEventAndType — eventId: $eventId type: $type');
      final snapshot = await _db
          .collection(_collection)
          .where('eventId', isEqualTo: eventId)
          .where('type', isEqualTo: type)
          .orderBy('uploadedAt', descending: true)
          .get();
      print('📋 fetchByEventAndType — found: ${snapshot.docs.length}');
      return snapshot.docs
          .map((e) => EventDrawModel.fromQuerySnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 fetchByEventAndType error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Add draw
  Future<String> addDraw(EventDrawModel draw) async {
    try {
      print('📋 addDraw — eventId: ${draw.eventId} type: ${draw.type}');
      final doc = await _db.collection(_collection).add(draw.toJson());
      print('📋 addDraw — created: ${doc.id}');
      return doc.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 addDraw error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update draw
  Future<void> updateDraw(EventDrawModel draw) async {
    try {
      print('📋 updateDraw — id: ${draw.id}');
      await _db.collection(_collection).doc(draw.id).update(draw.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 updateDraw error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update single field
  Future<void> updateField(String id, Map<String, dynamic> fields) async {
    try {
      print('📋 updateField — id: $id fields: ${fields.keys}');
      await _db.collection(_collection).doc(id).update(fields);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 updateField error: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Delete draw
  Future<void> deleteDraw(String id) async {
    try {
      print('📋 deleteDraw — id: $id');
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      print('🔴 deleteDraw error: $e');
      throw 'Something went wrong. Please try again';
    }
  }
}