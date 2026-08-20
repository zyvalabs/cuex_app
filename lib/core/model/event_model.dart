import 'package:cloud_firestore/cloud_firestore.dart';

/// Event/tournament data — written to Firestore's `Events` collection.
/// Individual matches created later can reference this event's id
/// (e.g. an `eventId` field on MatchModel) to link them together.
class EventModel {
  final String? id; // Firestore doc id — null until saved
  final String eventName;
  final String sport;
  final String format; // reds count / game type / race-to value — sport-specific
  final int? raceToPoints; // only set for Billiards

  final String createdBy;
  final DateTime createdAt;

  const EventModel({
    this.id,
    required this.eventName,
    required this.sport,
    required this.format,
    this.raceToPoints,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'sport': sport,
    'format': format,
    'raceToPoints': raceToPoints,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory EventModel.fromJson(Map<String, dynamic> data, {String? id}) {
    return EventModel(
      id: id,
      eventName: data['eventName'] ?? '',
      sport: data['sport'] ?? '',
      format: data['format'] ?? '',
      raceToPoints: data['raceToPoints'],
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}