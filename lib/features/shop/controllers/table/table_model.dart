import 'package:cloud_firestore/cloud_firestore.dart';

enum TableType { english, french, american, billiard }

class TableModel {
  final String id;
  final String venueId;
  final List<String> sportIds;
  final String tableName;
  final TableType? tableType;
  final String? brand;
  final int? maxPlayers;
  final String status;
  final DateTime createdAt;

  TableModel({
    required this.id,
    required this.venueId,
    required this.sportIds,
    required this.tableName,
    this.tableType,
    this.brand,
    this.maxPlayers,
    this.status = 'available',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static TableModel empty() => TableModel(
    id: '',
    venueId: '',
    sportIds: [],
    tableName: '',
  );

  factory TableModel.fromJson(Map<String, dynamic> json) => TableModel(
    id: json['id'] ?? '',
    venueId: json['venueId'] ?? '',
    sportIds: List<String>.from(json['sportIds'] ?? []),
    tableName: json['tableName'] ?? '',
    tableType: json['tableType'] != null ? TableType.values.byName(json['tableType']) : null,
    brand: json['brand'],
    maxPlayers: json['maxPlayers'],
    status: json['status'] ?? 'available',
    createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : DateTime.now(),
  );

  factory TableModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TableModel.fromJson({...data, 'id': doc.id});
  }

  factory TableModel.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TableModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => {
    'venueId': venueId,
    'sportIds': sportIds,
    'tableName': tableName,
    if (tableType != null) 'tableType': tableType!.name,
    if (brand != null) 'brand': brand,
    if (maxPlayers != null) 'maxPlayers': maxPlayers,
    'status': status,
    'createdAt': createdAt,
  };
}