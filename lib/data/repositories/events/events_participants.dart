import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/event_participant_model.dart';
import '../../abstract/base_repository.dart';

class EventParticipantRepository extends TBaseRepositoryController<EventParticipantModel> {
  static EventParticipantRepository get instance => Get.find();

  @override
  Future<List<EventParticipantModel>> fetchAllItems() async {
    try {
      final snapshot = await db.collection("EventParticipants").orderBy('registeredAt', descending: true).get();
      return snapshot.docs.map((e) => EventParticipantModel.fromQuerySnapshot(e)).toList();
    } catch (e) {
      print('🔴 fetchAllItems error: $e');
      rethrow;
    }
  }

  @override
  Future<EventParticipantModel> fetchSingleItem(String id) async {
    try {
      print('📋 fetchSingleItem — id: $id');
      final snapshot = await db.collection("EventParticipants").doc(id).get();
      if (!snapshot.exists || snapshot.data() == null) throw Exception('Participant $id not found');
      return EventParticipantModel.fromDocSnapshot(snapshot);
    } catch (e) {
      print('🔴 fetchSingleItem error: $e');
      rethrow;
    }
  }

  @override
  Future<String> addItem(EventParticipantModel item) async {
    try {
      print('📋 addItem — eventId: ${item.eventId} userId: ${item.userId}');
      final result = await db.collection("EventParticipants").add(item.toJson());
      print('📋 addItem — created: ${result.id}');
      return result.id;
    } catch (e) {
      print('🔴 addItem error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateItem(EventParticipantModel item) async {
    try {
      print('📋 updateItem — id: ${item.id}');
      await db.collection("EventParticipants").doc(item.id).update(item.toJson());
    } catch (e) {
      print('🔴 updateItem error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    try {
      print('📋 updateSingleField — id: $id fields: ${json.keys}');
      await db.collection("EventParticipants").doc(id).update(json);
    } catch (e) {
      print('🔴 updateSingleField error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(EventParticipantModel item) async {
    try {
      print('📋 deleteItem — id: ${item.id}');
      await db.collection("EventParticipants").doc(item.id).delete();
    } catch (e) {
      print('🔴 deleteItem error: $e');
      rethrow;
    }
  }

  @override
  EventParticipantModel fromQueryDocSnapshot(QueryDocumentSnapshot doc) {
    return EventParticipantModel.fromQuerySnapshot(doc);
  }

  @override
  Query getPaginatedQuery(limit) => db
      .collection('EventParticipants')
      .orderBy('registeredAt', descending: true)
      .limit(limit);

  /// Fetch all participants for a specific event
  Future<List<EventParticipantModel>> fetchParticipantsByEvent(String eventId) async {
    try {
      print('📋 fetchParticipantsByEvent — eventId: $eventId');
      final snapshot = await db
          .collection("EventParticipants")
          .where('eventId', isEqualTo: eventId)
          .orderBy('registeredAt', descending: false)
          .get();
      print('📋 fetchParticipantsByEvent — found: ${snapshot.docs.length}');
      return snapshot.docs.map((e) => EventParticipantModel.fromQuerySnapshot(e)).toList();
    } catch (e) {
      print('🔴 fetchParticipantsByEvent error: $e');
      rethrow;
    }
  }

  /// Fetch all events a user has participated in
  Future<List<EventParticipantModel>> fetchParticipantsByUser(String userId) async {
    try {
      print('📋 fetchParticipantsByUser — userId: $userId');
      final snapshot = await db
          .collection("EventParticipants")
          .where('userId', isEqualTo: userId)
          .orderBy('registeredAt', descending: true)
          .get();
      print('📋 fetchParticipantsByUser — found: ${snapshot.docs.length}');
      return snapshot.docs.map((e) => EventParticipantModel.fromQuerySnapshot(e)).toList();
    } catch (e) {
      print('🔴 fetchParticipantsByUser error: $e');
      rethrow;
    }
  }

  /// Fetch participants filtered by registration status
  Future<List<EventParticipantModel>> fetchParticipantsByStatus(String eventId, String status) async {
    try {
      print('📋 fetchParticipantsByStatus — eventId: $eventId status: $status');
      final snapshot = await db
          .collection("EventParticipants")
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: status)
          .orderBy('registeredAt', descending: false)
          .get();
      return snapshot.docs.map((e) => EventParticipantModel.fromQuerySnapshot(e)).toList();
    } catch (e) {
      print('🔴 fetchParticipantsByStatus error: $e');
      rethrow;
    }
  }

  /// Fetch participants filtered by payment status
  Future<List<EventParticipantModel>> fetchParticipantsByPaymentStatus(String eventId, String paymentStatus) async {
    try {
      print('📋 fetchParticipantsByPaymentStatus — eventId: $eventId paymentStatus: $paymentStatus');
      final snapshot = await db
          .collection("EventParticipants")
          .where('eventId', isEqualTo: eventId)
          .where('paymentStatus', isEqualTo: paymentStatus)
          .orderBy('registeredAt', descending: false)
          .get();
      return snapshot.docs.map((e) => EventParticipantModel.fromQuerySnapshot(e)).toList();
    } catch (e) {
      print('🔴 fetchParticipantsByPaymentStatus error: $e');
      rethrow;
    }
  }

  /// Check if user is registered for event (any status)
  Future<bool> isUserRegistered(String eventId, String userId) async {
    try {
      print('📋 isUserRegistered — eventId: $eventId userId: $userId');
      final snapshot = await db
          .collection("EventParticipants")
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      final exists = snapshot.docs.isNotEmpty;
      print('📋 isUserRegistered — exists: $exists');
      return exists;
    } catch (e) {
      print('🔴 isUserRegistered error: $e');
      return false;
    }
  }

  /// Get participant by event and user — returns null if not found
  Future<EventParticipantModel?> getParticipantByEventAndUser(String eventId, String userId) async {
    try {
      print('📋 getParticipantByEventAndUser — eventId: $eventId userId: $userId');
      final snapshot = await db
          .collection("EventParticipants")
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        print('📋 getParticipantByEventAndUser — not found');
        return null;
      }
      final participant = EventParticipantModel.fromQuerySnapshot(snapshot.docs.first);
      print('📋 getParticipantByEventAndUser — found: ${participant.id} status: ${participant.status}');
      return participant;
    } catch (e) {
      print('🔴 getParticipantByEventAndUser error: $e');
      return null;
    }
  }

  /// Count total participants for event
  Future<int> countParticipants(String eventId) async {
    try {
      print('📋 countParticipants — eventId: $eventId');
      final snapshot = await db
          .collection("EventParticipants")
          .where('eventId', isEqualTo: eventId)
          .count()
          .get();
      final count = snapshot.count ?? 0;
      print('📋 countParticipants — count: $count');
      return count;
    } catch (e) {
      print('🔴 countParticipants error: $e');
      return 0;
    }
  }

  /// Count only confirmed participants for event
  Future<int> countConfirmedParticipants(String eventId) async {
    try {
      print('📋 countConfirmedParticipants — eventId: $eventId');
      final snapshot = await db
          .collection("EventParticipants")
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'confirmed')
          .count()
          .get();
      final count = snapshot.count ?? 0;
      print('📋 countConfirmedParticipants — count: $count');
      return count;
    } catch (e) {
      print('🔴 countConfirmedParticipants error: $e');
      return 0;
    }
  }
}