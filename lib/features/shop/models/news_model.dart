import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String id;
  String title;
  String description;
  String imageUrl;
  String? videoUrl;
  String category;
  bool isPublished;
  String createdBy;
  DateTime createdAt;
  DateTime updatedAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.videoUrl,
    this.category = 'General',
    this.isPublished = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static NewsModel empty() => NewsModel(
    id: '',
    title: '',
    description: '',
    createdBy: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    if (videoUrl != null) 'videoUrl': videoUrl,
    'category': category,
    'isPublished': isPublished,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory NewsModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsModel.fromJson(doc.id, data);
  }

  factory NewsModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsModel.fromJson(doc.id, data);
  }

  factory NewsModel.fromJson(String id, Map<String, dynamic> data) => NewsModel(
    id: id,
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    imageUrl: data['imageUrl'] ?? '',
    videoUrl: data['videoUrl'],
    category: data['category'] ?? 'General',
    isPublished: data['isPublished'] ?? false,
    createdBy: data['createdBy'] ?? '',
    createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(),
  );
}