import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String venueId;
  final String tableId;
  final String sportId;
  final List<String> slotIds;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String status; // 'confirmed' | 'cancelled' | 'completed'
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.tableId,
    required this.sportId,
    required this.slotIds,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  static BookingModel empty() => BookingModel(
    id: '',
    userId: '',
    venueId: '',
    tableId: '',
    sportId: '',
    slotIds: [],
    date: DateTime.now(),
    startTime: '',
    endTime: '',
    totalAmount: 0.0,
    status: 'confirmed',
    createdAt: DateTime.now(),
  );

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    venueId: json['venueId'] ?? '',
    tableId: json['tableId'] ?? '',
    sportId: json['sportId'] ?? '',
    slotIds: List<String>.from(json['slotIds'] ?? []),
    date: json['date'] != null ? (json['date'] as Timestamp).toDate() : DateTime.now(),
    startTime: json['startTime'] ?? '',
    endTime: json['endTime'] ?? '',
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    status: json['status'] ?? 'confirmed',
    createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : DateTime.now(),
  );

  factory BookingModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel.fromJson({...data, 'id': doc.id});
  }

  factory BookingModel.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'venueId': venueId,
    'tableId': tableId,
    'sportId': sportId,
    'slotIds': slotIds,
    'date': date,
    'startTime': startTime,
    'endTime': endTime,
    'totalAmount': totalAmount,
    'status': status,
    'createdAt': createdAt,
  };
}