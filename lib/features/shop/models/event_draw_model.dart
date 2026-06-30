import 'package:cloud_firestore/cloud_firestore.dart';

class EventDrawModel {
  final String id;
  final String eventId;
  String title;
  String imageUrl;
  String type; // 'draw' or 'result'
  String uploadedBy;
  DateTime uploadedAt;
  DateTime updatedAt;

  EventDrawModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.imageUrl,
    required this.type,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.updatedAt,
  });

  static EventDrawModel empty() => EventDrawModel(
    id: '',
    eventId: '',
    title: '',
    imageUrl: '',
    type: 'draw',
    uploadedBy: '',
    uploadedAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'title': title,
    'imageUrl': imageUrl,
    'type': type,
    'uploadedBy': uploadedBy,
    'uploadedAt': Timestamp.fromDate(uploadedAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory EventDrawModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventDrawModel.fromJson(doc.id, data);
  }

  factory EventDrawModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventDrawModel.fromJson(doc.id, data);
  }

  factory EventDrawModel.fromJson(String id, Map<String, dynamic> data) =>
      EventDrawModel(
        id: id,
        eventId: data['eventId'] ?? '',
        title: data['title'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        type: data['type'] ?? 'draw',
        uploadedBy: data['uploadedBy'] ?? '',
        uploadedAt: data['uploadedAt'] != null
            ? (data['uploadedAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}