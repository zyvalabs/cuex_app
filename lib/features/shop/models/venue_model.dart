import 'package:cloud_firestore/cloud_firestore.dart';

class VenueModel {
  final String id;
  final String partnerId;
  final String name;
  final String city;
  final String address;
  final GeoPoint location;
  final String thumbnailImage;
  final List<String> images;
  final List<String> amenities;
  final String status;
  final bool isFeatured;
  final bool isActive;
  final bool streamingEnabled;
  final bool isTesting;
  final double rating;
  final int totalRatings;
  final int tablesCount;
  final DateTime createdAt;
  final String description;
  final List<String> sportIds;
  final String openTime;
  final String closeTime;
  final String? phone;
  final String? website;
  final Map<String, String>? socialLinks;

  VenueModel({
    required this.id,
    required this.partnerId,
    required this.name,
    required this.city,
    required this.address,
    required this.location,
    required this.thumbnailImage,
    required this.images,
    required this.amenities,
    required this.status,
    required this.isFeatured,
    required this.isActive,
    required this.streamingEnabled,
    this.isTesting = false,
    required this.rating,
    required this.totalRatings,
    required this.tablesCount,
    required this.createdAt,
    required this.description,
    required this.sportIds,
    required this.openTime,
    required this.closeTime,
    this.phone,
    this.website,
    this.socialLinks,
  });

  static VenueModel empty() => VenueModel(
    id: '',
    partnerId: '',
    name: '',
    city: '',
    address: '',
    location: const GeoPoint(0, 0),
    thumbnailImage: '',
    images: [],
    amenities: [],
    sportIds: [],
    status: 'closed',
    isFeatured: false,
    isActive: true,
    streamingEnabled: false,
    isTesting: false,
    rating: 0.0,
    totalRatings: 0,
    tablesCount: 0,
    createdAt: DateTime.now(),
    description: '',
    openTime: '09:00',
    closeTime: '23:00',
  );

  factory VenueModel.fromJson(Map<String, dynamic> json) => VenueModel(
    id: json['id'] ?? '',
    partnerId: json['partnerId'] ?? '',
    name: json['name'] ?? '',
    city: json['city'] ?? '',
    address: json['address'] ?? '',
    location: json['location'] ?? const GeoPoint(0, 0),
    thumbnailImage: json['thumbnailImage'] ?? '',
    images: List<String>.from(json['images'] ?? []),
    amenities: List<String>.from(json['amenities'] ?? []),
    status: json['status'] ?? 'closed',
    isFeatured: json['isFeatured'] ?? false,
    isActive: json['isActive'] ?? true,
    streamingEnabled: json['streamingEnabled'] ?? false,
    isTesting: json['isTesting'] ?? false,
    rating: (json['rating'] ?? 0).toDouble(),
    totalRatings: json['totalRatings'] ?? 0,
    tablesCount: json['tablesCount'] ?? 0,
    createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : DateTime.now(),
    description: json['description'] ?? '',
    sportIds: List<String>.from(json['sportIds'] ?? []),
    openTime: json['openTime'] ?? '09:00',
    closeTime: json['closeTime'] ?? '23:00',
    phone: json['phone'],
    website: json['website'],
    socialLinks: json['socialLinks'] != null ? Map<String, String>.from(json['socialLinks']) : null,
  );

  factory VenueModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VenueModel.fromJson({...data, 'id': doc.id});
  }

  factory VenueModel.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VenueModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() => {
    'partnerId': partnerId,
    'name': name,
    'city': city,
    'address': address,
    'location': location,
    'thumbnailImage': thumbnailImage,
    'images': images,
    'amenities': amenities,
    'status': status,
    'isFeatured': isFeatured,
    'isActive': isActive,
    'streamingEnabled': streamingEnabled,
    'isTesting': isTesting,
    'rating': rating,
    'totalRatings': totalRatings,
    'tablesCount': tablesCount,
    'createdAt': createdAt,
    'description': description,
    'sportIds': sportIds,
    'openTime': openTime,
    'closeTime': closeTime,
    if (phone != null) 'phone': phone,
    if (website != null) 'website': website,
    if (socialLinks != null) 'socialLinks': socialLinks,
  };
}