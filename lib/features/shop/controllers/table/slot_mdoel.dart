import 'package:cloud_firestore/cloud_firestore.dart';

class SlotModel {
  final String id;
  final String tableId;
  final String venueId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status; // 'available' | 'booked' | 'blocked'
  final double price;
  final double discountedPrice;
  final Map<String, double> pricingTiers; // {'1': 300, '2': 400, '4': 500}
  final DateTime createdAt;

  SlotModel({
    required this.id,
    required this.tableId,
    required this.venueId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
    required this.discountedPrice,
    required this.pricingTiers,
    required this.createdAt,
  });

  static SlotModel empty() => SlotModel(
    id: '',
    tableId: '',
    venueId: '',
    date: DateTime.now(),
    startTime: '',
    endTime: '',
    status: 'available',
    price: 0.0,
    discountedPrice: 0.0,
    pricingTiers: {},
    createdAt: DateTime.now(),
  );

  factory SlotModel.fromJson(Map<String, dynamic> json) => SlotModel(
    id: json['id'] ?? '',
    tableId: json['tableId'] ?? '',
    venueId: json['venueId'] ?? '',
    date: json['date'] != null ? (json['date'] as Timestamp).toDate() : DateTime.now(),
    startTime: json['startTime'] ?? '',
    endTime: json['endTime'] ?? '',
    status: json['status'] ?? 'available',
    price: (json['price'] ?? 0).toDouble(),
    discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
    pricingTiers: Map<String, double>.from(json['pricingTiers'] ?? {}),
    createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : DateTime.now(),
  );

  factory SlotModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SlotModel.fromJson({...data, 'id': doc.id});
  }

  factory SlotModel.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SlotModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => {
    'tableId': tableId,
    'venueId': venueId,
    'date': date,
    'startTime': startTime,
    'endTime': endTime,
    'status': status,
    'price': price,
    'discountedPrice': discountedPrice,
    'pricingTiers': pricingTiers,
    'createdAt': createdAt,
  };
}