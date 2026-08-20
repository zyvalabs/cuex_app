import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/model/match_model.dart';

/// Handles writing the final assembled match to Firestore.
/// Only responsibility: talk to the `Matches` collection — no UI state here.
class MatchRepository {
  final _firestore = FirebaseFirestore.instance;

  /// Writes a new match document and returns its generated Firestore ID.
  Future<String> createMatch(MatchModel match) async {
    // ignore: avoid_print
    print('🟣 [MatchRepository] Writing to Matches collection...');
    final docRef = await _firestore.collection('Matches').add(match.toJson());
    // ignore: avoid_print
    print('🟣 [MatchRepository] Document created with id: ${docRef.id}');
    return docRef.id;
  }

  /// Fetches an existing match by ID — useful later for editing/resuming.
  Future<MatchModel?> getMatch(String matchId) async {
    final doc = await _firestore.collection('Matches').doc(matchId).get();
    if (!doc.exists) return null;
    return MatchModel.fromJson(doc.data()!, id: doc.id);
  }

  /// Fetches all matches created by a given user, newest first.
  /// Used by MyMatchesController for the My Matches list screen.
  Future<List<MatchModel>> getUserMatches(String userId) async {
    // ignore: avoid_print
    print('🟣 [MatchRepository] Querying Matches where createdBy=$userId, ordered by createdAt desc...');

    final snapshot = await _firestore
        .collection('Matches')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    // ignore: avoid_print
    print('🟣 [MatchRepository] Query returned ${snapshot.docs.length} documents');

    return snapshot.docs.map((doc) => MatchModel.fromJson(doc.data(), id: doc.id)).toList();
  }

  /// Fetches all matches linked to a specific event, oldest first
  /// (so rounds show in the order they happened).
  Future<List<MatchModel>> getMatchesByEvent(String eventId) async {
    // ignore: avoid_print
    print('🟣 [MatchRepository] Querying Matches where eventId=$eventId...');

    final snapshot = await _firestore
        .collection('Matches')
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt', descending: false)
        .get();

    // ignore: avoid_print
    print('🟣 [MatchRepository] Query returned ${snapshot.docs.length} documents');

    return snapshot.docs.map((doc) => MatchModel.fromJson(doc.data(), id: doc.id)).toList();
  }

  /// Deletes a match document by ID.
  Future<void> deleteMatch(String matchId) async {
    // ignore: avoid_print
    print('🟣 [MatchRepository] Deleting match id=$matchId...');

    await _firestore.collection('Matches').doc(matchId).delete();

    // ignore: avoid_print
    print('🟣 [MatchRepository] Match deleted');
  }
}