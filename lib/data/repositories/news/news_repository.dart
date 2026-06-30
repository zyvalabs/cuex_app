import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/news_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class NewsRepository extends GetxController {
  static NewsRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'News';

  /// Fetch all published news — for players
  Future<List<NewsModel>> fetchPublishedNews() async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((e) => NewsModel.fromQuerySnapshot(e)).toList();
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

  /// Fetch all news — for admin (published + unpublished)
  Future<List<NewsModel>> fetchAllNews() async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((e) => NewsModel.fromQuerySnapshot(e)).toList();
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

  /// Fetch news by category
  Future<List<NewsModel>> fetchNewsByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('category', isEqualTo: category)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((e) => NewsModel.fromQuerySnapshot(e)).toList();
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

  /// Add news — admin only
  Future<String> addNews(NewsModel news) async {
    try {
      final doc = await _db.collection(_collection).add(news.toJson());
      return doc.id;
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

  /// Update news — admin only
  Future<void> updateNews(NewsModel news) async {
    try {
      await _db.collection(_collection).doc(news.id).update(news.toJson());
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

  /// Toggle publish status — admin only
  Future<void> togglePublish(String newsId, bool isPublished) async {
    try {
      await _db.collection(_collection).doc(newsId).update({
        'isPublished': isPublished,
        'updatedAt': DateTime.now(),
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

  /// Delete news — admin only
  Future<void> deleteNews(String newsId) async {
    try {
      await _db.collection(_collection).doc(newsId).delete();
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