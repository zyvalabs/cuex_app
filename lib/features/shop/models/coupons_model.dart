import 'package:cloud_firestore/cloud_firestore.dart';

class CouponsModel {
  final String id;
  final String venueId;
  final String code;
  final String discountType; // 'flat' | 'percentage'
  final double discountValue;
  final double minAmount;
  final int maxUses;
  final int usedCount;
  final List<String> applicableSlotIds; // empty = all slots
  final DateTime expiryDate;
  final bool isActive;
  final DateTime createdAt;

  CouponsModel({
    required this.id,
    required this.venueId,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minAmount,
    required this.maxUses,
    required this.usedCount,
    required this.applicableSlotIds,
    required this.expiryDate,
    required this.isActive,
    required this.createdAt,
  });

  static CouponsModel empty() => CouponsModel(
    id: '',
    venueId: '',
    code: '',
    discountType: 'flat',
    discountValue: 0.0,
    minAmount: 0.0,
    maxUses: 0,
    usedCount: 0,
    applicableSlotIds: [],
    expiryDate: DateTime.now(),
    isActive: true,
    createdAt: DateTime.now(),
  );

  double get discountAmount => discountType == 'percentage' ? discountValue : discountValue;

  bool get isValid => isActive && usedCount < maxUses && expiryDate.isAfter(DateTime.now());

  factory CouponsModel.fromJson(Map<String, dynamic> json) => CouponsModel(
    id: json['id'] ?? '',
    venueId: json['venueId'] ?? '',
    code: json['code'] ?? '',
    discountType: json['discountType'] ?? 'flat',
    discountValue: (json['discountValue'] ?? 0).toDouble(),
    minAmount: (json['minAmount'] ?? 0).toDouble(),
    maxUses: json['maxUses'] ?? 0,
    usedCount: json['usedCount'] ?? 0,
    applicableSlotIds: List<String>.from(json['applicableSlotIds'] ?? []),
    expiryDate: json['expiryDate'] != null ? (json['expiryDate'] as Timestamp).toDate() : DateTime.now(),
    isActive: json['isActive'] ?? true,
    createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : DateTime.now(),
  );

  factory CouponsModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponsModel.fromJson({...data, 'id': doc.id});
  }

  factory CouponsModel.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponsModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => {
    'venueId': venueId,
    'code': code,
    'discountType': discountType,
    'discountValue': discountValue,
    'minAmount': minAmount,
    'maxUses': maxUses,
    'usedCount': usedCount,
    'applicableSlotIds': applicableSlotIds,
    'expiryDate': expiryDate,
    'isActive': isActive,
    'createdAt': createdAt,
  };
}