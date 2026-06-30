import 'package:cloud_firestore/cloud_firestore.dart';

class StreamingCreditsModel {
  final String id; // venueId or userId
  final int totalCredits;
  final int usedCredits;
  final int remainingCredits;
  final DateTime? lastPurchasedAt;
  final DateTime? lastUsedAt;
  final List<Map<String, dynamic>> transactions;

  StreamingCreditsModel({
    required this.id,
    required this.totalCredits,
    required this.usedCredits,
    required this.remainingCredits,
    this.lastPurchasedAt,
    this.lastUsedAt,
    this.transactions = const [],
  });

  static StreamingCreditsModel empty() => StreamingCreditsModel(
    id: '',
    totalCredits: 0,
    usedCredits: 0,
    remainingCredits: 0,
    transactions: [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'totalCredits': totalCredits,
    'usedCredits': usedCredits,
    'remainingCredits': remainingCredits,
    if (lastPurchasedAt != null) 'lastPurchasedAt': Timestamp.fromDate(lastPurchasedAt!),
    if (lastUsedAt != null) 'lastUsedAt': Timestamp.fromDate(lastUsedAt!),
    'transactions': transactions,
  };

  factory StreamingCreditsModel.fromJson(String id, Map<String, dynamic> data) => StreamingCreditsModel(
    id: id,
    totalCredits: data['totalCredits'] ?? 0,
    usedCredits: data['usedCredits'] ?? 0,
    remainingCredits: data['remainingCredits'] ?? 0,
    lastPurchasedAt: data['lastPurchasedAt'] != null ? (data['lastPurchasedAt'] as Timestamp).toDate() : null,
    lastUsedAt: data['lastUsedAt'] != null ? (data['lastUsedAt'] as Timestamp).toDate() : null,
    transactions: List<Map<String, dynamic>>.from(data['transactions'] ?? []),
  );

  factory StreamingCreditsModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreamingCreditsModel.fromJson(doc.id, data);
  }
}