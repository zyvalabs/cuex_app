import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import '../../../features/shop/models/streaming_credit_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class StreamingCreditsRepository extends GetxController {
  static StreamingCreditsRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'StreamingCredits';

  /// Fetch credits for a venue or user by their ID
  Future<StreamingCreditsModel?> fetchCredits(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return StreamingCreditsModel.fromDocSnapshot(doc);
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

  /// Check if venue/user has remaining credits
  Future<bool> hasCredits(String id) async {
    try {
      final credits = await fetchCredits(id);
      if (credits == null) return false;
      return credits.remainingCredits > 0;
    } catch (e) {
      return false;
    }
  }

  /// Add credits after purchase
  /// Creates doc if doesn't exist, otherwise increments
  Future<void> addCredits({
    required String id,
    required int credits,
    required double amount,
    required String paymentRef,
    String? note,
  }) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();

      final transaction = {
        'credits': credits,
        'amount': amount,
        'purchasedAt': Timestamp.now(),
        'paymentRef': paymentRef,
        'note': note ?? 'Purchased $credits streaming credits',
      };

      if (!doc.exists) {
        // Create new credits doc
        await _db.collection(_collection).doc(id).set({
          'id': id,
          'totalCredits': credits,
          'usedCredits': 0,
          'remainingCredits': credits,
          'lastPurchasedAt': Timestamp.now(),
          'lastUsedAt': null,
          'transactions': [transaction],
        });
      } else {
        // Increment existing credits
        await _db.collection(_collection).doc(id).update({
          'totalCredits': FieldValue.increment(credits),
          'remainingCredits': FieldValue.increment(credits),
          'lastPurchasedAt': Timestamp.now(),
          'transactions': FieldValue.arrayUnion([transaction]),
        });
      }
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

  /// Deduct 1 credit when a match goes live
  /// Returns false if no credits remaining
  Future<bool> deductCredit(String id) async {
    try {
      final credits = await fetchCredits(id);

      // No credits doc or no remaining credits
      if (credits == null || credits.remainingCredits <= 0) return false;

      await _db.collection(_collection).doc(id).update({
        'usedCredits': FieldValue.increment(1),
        'remainingCredits': FieldValue.increment(-1),
        'lastUsedAt': Timestamp.now(),
      });

      return true;
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

  /// Refund 1 credit — used if match is cancelled after credit deducted
  Future<void> refundCredit(String id) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'usedCredits': FieldValue.increment(-1),
        'remainingCredits': FieldValue.increment(1),
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

  /// Admin manually sets credits — override total
  Future<void> setCredits({
    required String id,
    required int totalCredits,
    required int usedCredits,
  }) async {
    try {
      await _db.collection(_collection).doc(id).set({
        'id': id,
        'totalCredits': totalCredits,
        'usedCredits': usedCredits,
        'remainingCredits': totalCredits - usedCredits,
        'lastPurchasedAt': Timestamp.now(),
        'lastUsedAt': null,
        'transactions': [],
      }, SetOptions(merge: true));
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