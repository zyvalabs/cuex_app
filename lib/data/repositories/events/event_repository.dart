import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/personalization/controllers/user_controller.dart';
import '../../../features/personalization/models/user_model.dart';
import '../../../features/shop/models/event_model.dart';
import '../../../utils/constants/enums.dart';
import '../../abstract/base_repository.dart';
import '../user/user_repository.dart';

class EventRepository extends TBaseRepositoryController<EventModel> {
  static EventRepository get instance => Get.find();

  bool get _isAdmin {
    try {
      return Get.find<UserController>().user.value.role == AppRole.admin;
    } catch (_) {
      return false;
    }
  }



  List<EventModel> _filterForNonAdmin(List<EventModel> events) {
    return events.where((e) => !e.isTesting && e.isPublic).toList();
  }

  @override
  Future<List<EventModel>> fetchAllItems() async {
    final snapshot = await db.collection("Events").orderBy('createdAt', descending: true).get();
    final events = snapshot.docs.map((e) => EventModel.fromQuerySnapshot(e)).toList();
    return _isAdmin ? events : _filterForNonAdmin(events);
  }

  @override
  Future<EventModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection("Events").doc(id).get();
    return EventModel.fromDocSnapshot(snapshot);
  }

  @override
  Future<String> addItem(EventModel item) async {
    final result = await db.collection("Events").add(item.toJson());
    return result.id;
  }

  @override
  Future<void> updateItem(EventModel item) async {
    await db.collection("Events").doc(item.id).update(item.toJson());
  }

  @override
  Future<void> deleteItem(EventModel item) async {
    await db.collection("Events").doc(item.id).delete();
  }

  @override
  EventModel fromQueryDocSnapshot(QueryDocumentSnapshot doc) {
    return EventModel.fromQuerySnapshot(doc);
  }

  @override
  Query getPaginatedQuery(limit) => db.collection('Events').orderBy('createdAt', descending: true).limit(limit);

  Future<List<EventModel>> fetchEventsByStatus(String status) async {
    try {
      print('🎯 fetchEventsByStatus: $status');
      final snapshot = await db
          .collection("Events")
          .where('eventStatus', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      print('🎯 found ${snapshot.docs.length} events for status: $status');
      final events = snapshot.docs.map((e) => EventModel.fromQuerySnapshot(e)).toList();
      return _isAdmin ? events : _filterForNonAdmin(events);
    } catch (e) {
      print('🔴 fetchEventsByStatus error: $e');
      rethrow;
    }
  }

  Future<List<EventModel>> fetchUpcomingEvents() async {
    try {
      print('🎯 fetchUpcomingEvents called');
      final snapshot = await db
          .collection("Events")
          .where('eventStatus', isEqualTo: 'upcoming')
          .orderBy('createdAt', descending: true)
          .get();
      print('🎯 found ${snapshot.docs.length} upcoming events');
      final events = snapshot.docs.map((e) => EventModel.fromQuerySnapshot(e)).toList();
      return _isAdmin ? events : _filterForNonAdmin(events);
    } catch (e) {
      print('🔴 fetchUpcomingEvents error: $e');
      rethrow;
    }
  }

  Future<List<EventModel>> fetchEventsByDateRange(DateTime start, DateTime end) async {
    final startTimestamp = Timestamp.fromDate(start);
    final endTimestamp = Timestamp.fromDate(end);
    final snapshot = await db
        .collection("Events")
        .where('startDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('startDate', isLessThanOrEqualTo: endTimestamp)
        .orderBy('startDate', descending: false)
        .get();
    final events = snapshot.docs.map((e) => EventModel.fromQuerySnapshot(e)).toList();
    return _isAdmin ? events : _filterForNonAdmin(events);
  }

  Future<List<EventModel>> fetchEventsBySport(String sportId) async {
    final snapshot = await db
        .collection("Events")
        .where('sportId', isEqualTo: sportId)
        .orderBy('createdAt', descending: true)
        .get();
    final events = snapshot.docs.map((e) => EventModel.fromQuerySnapshot(e)).toList();
    return _isAdmin ? events : _filterForNonAdmin(events);
  }

  Future<List<EventModel>> searchEventsByName(String query) async {
    final snapshot = await db
        .collection("Events")
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .orderBy('name')
        .get();
    final events = snapshot.docs.map((e) => EventModel.fromQuerySnapshot(e)).toList();
    return _isAdmin ? events : _filterForNonAdmin(events);
  }

  Future<List<EventModel>> fetchFeaturedEvents() async {
    final snapshot = await db
        .collection("Events")
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(6)
        .get();
    final events = snapshot.docs.map((e) => EventModel.fromQuerySnapshot(e)).toList();
    return _isAdmin ? events : _filterForNonAdmin(events);
  }

  Future<List<EventModel>> fetchEventsByVenue(String venueId) async {
    final snapshot = await db
        .collection("Events")
        .where('venueId', isEqualTo: venueId)
        .orderBy('createdAt', descending: true)
        .get();
    final events = snapshot.docs.map((e) => EventModel.fromQuerySnapshot(e)).toList();
    return _isAdmin ? events : _filterForNonAdmin(events);
  }

  Future<UserModel?> fetchEventWinner(String eventId) async {
    final event = await fetchSingleItem(eventId);
    if (event.winnerId == null || event.winnerId!.isEmpty) return null;
    return await UserRepository.instance.fetchUserById(event.winnerId!);
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection("Events").doc(id).update(json);
  }
}