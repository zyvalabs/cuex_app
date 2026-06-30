import 'package:cloud_firestore/cloud_firestore.dart';

class EventParticipantModel {
  String id;
  String eventId;
  String userId;
  String status; // 'registered', 'confirmed', 'withdrawn', 'disqualified'
  String paymentStatus; // 'pending', 'paid', 'refunded', 'waived'
  double? amountPaid;
  String? paymentMethod; // 'cash', 'card', 'upi', 'online'
  String? transactionId;
  DateTime registeredAt;
  DateTime? confirmedAt;
  DateTime? withdrawnAt;
  String? withdrawalReason;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  EventParticipantModel({
    required this.id,
    required this.eventId,
    required this.userId,
    this.status = 'registered',
    this.paymentStatus = 'pending',
    this.amountPaid,
    this.paymentMethod,
    this.transactionId,
    required this.registeredAt,
    this.confirmedAt,
    this.withdrawnAt,
    this.withdrawalReason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  static EventParticipantModel empty() => EventParticipantModel(
    id: '',
    eventId: '',
    userId: '',
    registeredAt: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'status': status,
      'paymentStatus': paymentStatus,
      'amountPaid': amountPaid,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'withdrawnAt': withdrawnAt != null ? Timestamp.fromDate(withdrawnAt!) : null,
      'withdrawalReason': withdrawalReason,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory EventParticipantModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventParticipantModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'registered',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      amountPaid: data['amountPaid']?.toDouble(),
      paymentMethod: data['paymentMethod'],
      transactionId: data['transactionId'],
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      confirmedAt: data['confirmedAt'] != null ? (data['confirmedAt'] as Timestamp).toDate() : null,
      withdrawnAt: data['withdrawnAt'] != null ? (data['withdrawnAt'] as Timestamp).toDate() : null,
      withdrawalReason: data['withdrawalReason'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory EventParticipantModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    print('Parsing participant doc: ${doc.id}');
    final data = doc.data() as Map<String, dynamic>;
    print('Document data: $data');

    try {
      return EventParticipantModel(
        id: doc.id,
        eventId: data['eventId'] ?? '',
        userId: data['userId'] ?? '',
        status: data['status'] ?? 'registered',
        paymentStatus: data['paymentStatus'] ?? 'pending',
        amountPaid: data['amountPaid']?.toDouble(),
        paymentMethod: data['paymentMethod'],
        transactionId: data['transactionId'],
        registeredAt: (data['registeredAt'] as Timestamp).toDate(),
        confirmedAt: data['confirmedAt'] != null ? (data['confirmedAt'] as Timestamp).toDate() : null,
        withdrawnAt: data['withdrawnAt'] != null ? (data['withdrawnAt'] as Timestamp).toDate() : null,
        withdrawalReason: data['withdrawalReason'],
        notes: data['notes'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('ERROR parsing participant: $e');
      rethrow;
    }
  }

  }
