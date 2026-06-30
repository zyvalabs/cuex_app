import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

import '../../../features/shop/models/match_model.dart';
import '../../abstract/base_repository.dart';

class MatchRepository extends TBaseRepositoryController<MatchModel> {
  static MatchRepository get instance => Get.find();

  void _log(String msg) {
    if (kDebugMode) dev.log('[MatchRepo] $msg');
  }

  @override
  Future<List<MatchModel>> fetchAllItems() async {
    final snapshot = await db
        .collection('Matches')
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: true)
        .get();
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  @override
  Future<MatchModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection('Matches').doc(id).get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('Match $id not found');
    }
    return MatchModel.fromDocSnapshot(snapshot);
  }

  @override
  Future<String> addItem(MatchModel item) async {
    final result = await db.collection('Matches').add(item.toJson());
    _log('addItem — created: ${result.id}');
    return result.id;
  }

  @override
  Future<void> updateItem(MatchModel item) async {
    await db.collection('Matches').doc(item.id).update(item.toJson());
    _log('updateItem — updated: ${item.id}');
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection('Matches').doc(id).update(json);
    _log('updateSingleField — id: $id fields: ${json.keys}');
  }

  @override
  Future<void> deleteItem(MatchModel item) async {
    await db.collection('Matches').doc(item.id).delete();
    _log('deleteItem — deleted: ${item.id}');
  }

  @override
  MatchModel fromQueryDocSnapshot(QueryDocumentSnapshot doc) {
    return MatchModel.fromQuerySnapshot(doc);
  }

  @override
  Query getPaginatedQuery(limit) => db
      .collection('Matches')
      .where('isTesting', isEqualTo: false) // ✅
      .orderBy('scheduledTime', descending: true)
      .limit(limit);

  // ─────────────────────────────────────────
  // Fetch by status
  // ─────────────────────────────────────────

  Future<List<MatchModel>> fetchLiveMatches({String? matchType}) async {
    Query query = db
        .collection('Matches')
        .where('matchStatus', isEqualTo: 'live')
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: true);
    if (matchType != null) {
      query = query.where('matchType', isEqualTo: matchType);
    }
    final snapshot = await query.get();
    _log('fetchLiveMatches — count: ${snapshot.docs.length}');
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  Future<List<MatchModel>> fetchUpcomingMatches({String? matchType}) async {
    Query query = db
        .collection('Matches')
        .where('matchStatus', isEqualTo: 'upcoming')
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: false);
    if (matchType != null) {
      query = query.where('matchType', isEqualTo: matchType);
    }
    final snapshot = await query.get();
    _log('fetchUpcomingMatches — count: ${snapshot.docs.length}');
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  Future<List<MatchModel>> fetchCompletedMatches({String? matchType}) async {
    Query query = db
        .collection('Matches')
        .where('matchStatus', isEqualTo: 'completed')
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: true);
    if (matchType != null) {
      query = query.where('matchType', isEqualTo: matchType);
    }
    final snapshot = await query.get();
    _log('fetchCompletedMatches — count: ${snapshot.docs.length}');
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  // ─────────────────────────────────────────
  // Fetch by relation
  // ─────────────────────────────────────────

  Future<List<MatchModel>> fetchMatchesByEvent(String eventId) async {
    final snapshot = await db
        .collection('Matches')
        .where('eventId', isEqualTo: eventId)
        .orderBy('scheduledTime', descending: false)
        .get();
    _log('fetchMatchesByEvent — eventId: $eventId count: ${snapshot.docs.length}');
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  Future<List<MatchModel>> fetchMatchesByVenue(String venueId) async {
    final eventsSnapshot = await db
        .collection('Events')
        .where('venueId', isEqualTo: venueId)
        .where('isTesting', isEqualTo: false) // ✅
        .get();
    final eventIds = eventsSnapshot.docs.map((e) => e.id).toList();
    if (eventIds.isEmpty) return [];
    final snapshot = await db
        .collection('Matches')
        .where('eventId', whereIn: eventIds)
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: false)
        .get();
    _log('fetchMatchesByVenue — venueId: $venueId count: ${snapshot.docs.length}');
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  Future<List<MatchModel>> fetchMatchesByPlayer(String playerId) async {
    final snapshot1 = await db
        .collection('Matches')
        .where('player1Id', isEqualTo: playerId)
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: true)
        .get();
    final snapshot2 = await db
        .collection('Matches')
        .where('player2Id', isEqualTo: playerId)
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: true)
        .get();
    final ids = <String>{};
    final all = [
      ...snapshot1.docs.map((e) => MatchModel.fromQuerySnapshot(e)),
      ...snapshot2.docs.map((e) => MatchModel.fromQuerySnapshot(e)),
    ].where((m) => ids.add(m.id)).toList();
    all.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    _log('fetchMatchesByPlayer — playerId: $playerId count: ${all.length}');
    return all;
  }

  Future<List<MatchModel>> fetchTodayCompletedMatches() async {
    final now = DateTime.now();
    final start =
    Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final end = Timestamp.fromDate(
        DateTime(now.year, now.month, now.day, 23, 59));
    final snapshot = await db
        .collection('Matches')
        .where('matchStatus', isEqualTo: 'completed')
        .where('isTesting', isEqualTo: false) // ✅
        .where('updatedAt', isGreaterThanOrEqualTo: start)
        .where('updatedAt', isLessThanOrEqualTo: end)
        .get();
    _log('fetchTodayCompletedMatches — count: ${snapshot.docs.length}');
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  Future<List<MatchModel>> fetchFeaturedMatches() async {
    final snapshot = await db
        .collection('Matches')
        .where('isFeatured', isEqualTo: true)
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: false)
        .limit(6)
        .get();
    _log('fetchFeaturedMatches — count: ${snapshot.docs.length}');
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  Future<List<MatchModel>> fetchMatchesByStatus(String status) async {
    final snapshot = await db
        .collection('Matches')
        .where('matchStatus', isEqualTo: status)
        .where('isTesting', isEqualTo: false) // ✅
        .orderBy('scheduledTime', descending: false)
        .get();
    _log('fetchMatchesByStatus — status: $status count: ${snapshot.docs.length}');
    return snapshot.docs.map((e) => MatchModel.fromQuerySnapshot(e)).toList();
  }

  Stream<MatchModel> watchMatch(String matchId) {
    return db
        .collection('Matches')
        .doc(matchId)
        .snapshots()
        .map((doc) => MatchModel.fromDocSnapshot(doc));
  }
}