import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/constants/enums.dart';

class EventModel {
  String id;
  String name;
  String venueId;
  DateTime startDate;
  DateTime endDate;
  DateTime registrationDeadline;
  int maxParticipants;
  int registrationCount;
  EventStatus eventStatus;
  String format;
  String participantType;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;
  String? description;
  bool isFeatured;
  bool isVerified;
  bool isPublic;
  bool isTesting;
  double? entryFee;
  double? prizePool;
  String? winnerId;
  String? sportId;
  List<Map<String, dynamic>> prizes;

  EventModel({
    required this.id,
    required this.name,
    required this.venueId,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.maxParticipants,
    this.registrationCount = 0,
    required this.eventStatus,
    required this.format,
    required this.participantType,
    this.imageUrl = '',
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.isFeatured = false,
    this.isVerified = false,
    this.isPublic = true,
    this.isTesting = false,
    this.entryFee,
    this.prizePool,
    this.winnerId,
    this.sportId,
    this.prizes = const [],
  });

  static EventModel empty() => EventModel(
    id: '',
    name: '',
    venueId: '',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    registrationDeadline: DateTime.now(),
    maxParticipants: 0,
    registrationCount: 0,
    eventStatus: EventStatus.upcoming,
    format: '',
    participantType: '',
    description: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isFeatured: false,
    isVerified: false,
    isPublic: true,
    isTesting: false,
    prizes: [],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'venueId': venueId,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'registrationDeadline': Timestamp.fromDate(registrationDeadline),
    'maxParticipants': maxParticipants,
    'registrationCount': registrationCount,
    'eventStatus': eventStatus.value,
    'format': format,
    'participantType': participantType,
    'imageUrl': imageUrl,
    'description': description,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'isFeatured': isFeatured,
    'isVerified': isVerified,
    'isPublic': isPublic,
    'isTesting': isTesting,
    'prizes': prizes,
    if (entryFee != null) 'entryFee': entryFee,
    if (prizePool != null) 'prizePool': prizePool,
    if (winnerId != null) 'winnerId': winnerId,
    if (sportId != null) 'sportId': sportId,
  };

  factory EventModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      name: data['name'] ?? '',
      venueId: data['venueId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      registrationDeadline: (data['registrationDeadline'] as Timestamp).toDate(),
      maxParticipants: data['maxParticipants'] ?? 0,
      registrationCount: data['registrationCount'] ?? 0,
      eventStatus: EventStatusX.fromString(data['eventStatus'] ?? 'upcoming'),
      format: data['format'] ?? '',
      participantType: data['participantType'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isFeatured: data['isFeatured'] ?? false,
      isVerified: data['isVerified'] ?? false,
      isPublic: data['isPublic'] ?? true,
      isTesting: data['isTesting'] ?? false,
      entryFee: data['entryFee']?.toDouble(),
      prizePool: data['prizePool']?.toDouble(),
      winnerId: data['winnerId'],
      sportId: data['sportId'],
      prizes: List<Map<String, dynamic>>.from(data['prizes'] ?? []),
    );
  }

  factory EventModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      name: data['name'] ?? '',
      venueId: data['venueId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      registrationDeadline: (data['registrationDeadline'] as Timestamp).toDate(),
      maxParticipants: data['maxParticipants'] ?? 0,
      registrationCount: data['registrationCount'] ?? 0,
      eventStatus: EventStatusX.fromString(data['eventStatus'] ?? 'upcoming'),
      format: data['format'] ?? '',
      participantType: data['participantType'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isFeatured: data['isFeatured'] ?? false,
      isVerified: data['isVerified'] ?? false,
      isPublic: data['isPublic'] ?? true,
      isTesting: data['isTesting'] ?? false,
      entryFee: data['entryFee']?.toDouble(),
      prizePool: data['prizePool']?.toDouble(),
      winnerId: data['winnerId'],
      sportId: data['sportId'],
      prizes: List<Map<String, dynamic>>.from(data['prizes'] ?? []),
    );
  }
}