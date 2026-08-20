import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/model/event_model.dart';

/// Handles writing/reading events to/from Firestore's `Events` collection.
class EventRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<String> createEvent(EventModel event) async {
    // ignore: avoid_print
    print('🟣 [EventRepository] Writing to Events collection...');

    final docRef = await _firestore.collection('Events').add(event.toJson());

    // ignore: avoid_print
    print('🟣 [EventRepository] Document created with id: ${docRef.id}');

    return docRef.id;
  }

  Future<List<EventModel>> getUserEvents(String userId) async {
    final snapshot = await _firestore
        .collection('Events')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => EventModel.fromJson(doc.data(), id: doc.id)).toList();
  }
}