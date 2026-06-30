import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String id;
  String title;
  String buttonTitle;
  String imageUrl;
  String videoUrl;
  String linkType; // 'internal' or 'external'
  String linkRoute; // named route e.g. '/events' or external URL
  String type; // 'image' or 'video'
  bool isActive;
  int order;
  int viewCount;
  String createdBy;
  DateTime createdAt;
  DateTime updatedAt;

  PromotionModel({
    required this.id,
    required this.title,
    required this.buttonTitle,
    required this.imageUrl,
    required this.videoUrl,
    required this.linkType,
    required this.linkRoute,
    required this.type,
    required this.isActive,
    required this.order,
    required this.viewCount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static PromotionModel empty() => PromotionModel(
    id: '',
    title: '',
    buttonTitle: 'Explore Now',
    imageUrl: '',
    videoUrl: '',
    linkType: 'internal',
    linkRoute: '/events',
    type: 'image',
    isActive: true,
    order: 0,
    viewCount: 0,
    createdBy: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'buttonTitle': buttonTitle,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'linkType': linkType,
    'linkRoute': linkRoute,
    'type': type,
    'isActive': isActive,
    'order': order,
    'viewCount': viewCount,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory PromotionModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromotionModel.fromJson(doc.id, data);
  }

  factory PromotionModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromotionModel.fromJson(doc.id, data);
  }

  factory PromotionModel.fromJson(String id, Map<String, dynamic> data) =>
      PromotionModel(
        id: id,
        title: data['title'] ?? '',
        buttonTitle: data['buttonTitle'] ?? 'Explore Now',
        imageUrl: data['imageUrl'] ?? '',
        videoUrl: data['videoUrl'] ?? '',
        linkType: data['linkType'] ?? 'internal',
        linkRoute: data['linkRoute'] ?? '/events',
        type: data['type'] ?? 'image',
        isActive: data['isActive'] ?? true,
        order: data['order'] ?? 0,
        viewCount: data['viewCount'] ?? 0,
        createdBy: data['createdBy'] ?? '',
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  PromotionModel copyWith({
    String? title,
    String? buttonTitle,
    String? imageUrl,
    String? videoUrl,
    String? linkType,
    String? linkRoute,
    String? type,
    bool? isActive,
    int? order,
    int? viewCount,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      PromotionModel(
        id: id,
        title: title ?? this.title,
        buttonTitle: buttonTitle ?? this.buttonTitle,
        imageUrl: imageUrl ?? this.imageUrl,
        videoUrl: videoUrl ?? this.videoUrl,
        linkType: linkType ?? this.linkType,
        linkRoute: linkRoute ?? this.linkRoute,
        type: type ?? this.type,
        isActive: isActive ?? this.isActive,
        order: order ?? this.order,
        viewCount: viewCount ?? this.viewCount,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}