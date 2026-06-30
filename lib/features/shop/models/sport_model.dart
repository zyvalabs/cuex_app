import 'package:cloud_firestore/cloud_firestore.dart';

class SportModel {
  final String id;
  String name;
  String iconUrl; // renamed from icon — supports both upload URL and external URL
  bool isActive;
  bool isFeatured;
  bool isTesting;
  int order;
  String? description;
  DateTime createdAt;
  DateTime updatedAt;

  SportModel({
    required this.id,
    required this.name,
    this.iconUrl = '',
    this.isActive = true,
    this.isFeatured = false,
    this.isTesting = false,
    this.order = 0,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  static SportModel empty() => SportModel(
    id: '',
    name: '',
    iconUrl: '',
    isActive: true,
    isFeatured: false,
    isTesting: false,
    order: 0,
    description: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'iconUrl': iconUrl,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'isTesting': isTesting,
    'order': order,
    'description': description,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  /// From plain JSON map — used for cached storage
  factory SportModel.fromJson(Map<String, dynamic> data) => SportModel(
    id: data['id'] ?? '',
    name: data['name'] ?? '',
    iconUrl: data['iconUrl'] ?? data['icon'] ?? '', // backward compat with old 'icon' field
    isActive: data['isActive'] ?? true,
    isFeatured: data['isFeatured'] ?? false,
    isTesting: data['isTesting'] ?? false,
    order: data['order'] ?? 0,
    description: data['description'],
    createdAt: data['createdAt'] != null
        ? data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now(),
    updatedAt: data['updatedAt'] != null
        ? data['updatedAt'] is Timestamp
        ? (data['updatedAt'] as Timestamp).toDate()
        : DateTime.tryParse(data['updatedAt'].toString()) ?? DateTime.now()
        : DateTime.now(),
  );

  /// From Firestore DocumentSnapshot
  factory SportModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SportModel.fromJson({...data, 'id': doc.id});
  }

  /// From Firestore QueryDocumentSnapshot
  factory SportModel.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SportModel.fromJson({...data, 'id': doc.id});
  }

  /// Alias — used by new repo pattern
  factory SportModel.fromDocSnapshot(DocumentSnapshot doc) =>
      SportModel.fromDocumentSnapshot(doc);

  /// Alias — used by new repo pattern
  factory SportModel.fromQuerySnapshot(QueryDocumentSnapshot doc) =>
      SportModel.fromQueryDocumentSnapshot(doc);

  SportModel copyWith({
    String? name,
    String? iconUrl,
    bool? isActive,
    bool? isFeatured,
    bool? isTesting,
    int? order,
    String? description,
    DateTime? updatedAt,
  }) =>
      SportModel(
        id: id,
        name: name ?? this.name,
        iconUrl: iconUrl ?? this.iconUrl,
        isActive: isActive ?? this.isActive,
        isFeatured: isFeatured ?? this.isFeatured,
        isTesting: isTesting ?? this.isTesting,
        order: order ?? this.order,
        description: description ?? this.description,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}