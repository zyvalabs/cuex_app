import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/formatters/formatter.dart';
import 'address_model.dart';

class UserModel {
  final String id;
  String firstName;
  String lastName;
  String userName;
  String email;
  String phoneNumber;
  String pin;
  String profilePicture;
  String gender;
  String city;
  DateTime? dob;
  AppRole role;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isProfileActive;
  bool isEmailVerified;
  VerificationStatus verificationStatus;
  int points;
  int orderCount;
  String deviceToken;
  List<AddressModel>? addresses;
  List<String>? reviewedProducts;

  UserModel({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.userName = '',
    this.phoneNumber = '',
    this.pin = '',
    this.profilePicture = '',
    this.gender = '',
    this.city = '',
    this.dob,
    this.role = AppRole.player,
    this.createdAt,
    this.updatedAt,
    this.deviceToken = '',
    required this.isEmailVerified,
    required this.isProfileActive,
    this.points = 0,
    this.orderCount = 0,
    this.verificationStatus = VerificationStatus.unknown,
    this.addresses,
    this.reviewedProducts,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);
  String get formattedDate => TFormatter.formatDateAndTime(createdAt);
  String get formattedUpdatedAtDate => TFormatter.formatDateAndTime(updatedAt);

  static List<String> nameParts(fullName) => fullName.split(" ");

  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";
    return "cuex_$firstName$lastName";
  }

  static UserModel empty() => UserModel(id: '', email: '', isEmailVerified: false, isProfileActive: false);

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'userName': userName,
    'email': email,
    'phoneNumber': phoneNumber,
    'pin': pin,
    'profilePicture': profilePicture,
    'gender': gender,
    'city': city,
    if (dob != null) 'dob': Timestamp.fromDate(dob!),
    'role': role.name.toString(),
    'isEmailVerified': isEmailVerified,
    'isProfileActive': isProfileActive,
    'points': points,
    'orderCount': orderCount,
    'deviceToken': deviceToken,
    'reviewedProducts': reviewedProducts,
    'verificationStatus': verificationStatus.name,
    'createdAt': createdAt,
    'updatedAt': DateTime.now(),
  };

  factory UserModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel.fromJson(doc.id, data);
  }

  static UserModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(doc.id, data);
  }

  factory UserModel.fromJson(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      pin: data['pin'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      gender: data['gender'] ?? '',
      city: data['city'] ?? '',
      dob: data['dob'] != null ? (data['dob'] as Timestamp).toDate() : null,
      role: data.containsKey('role') ? _parseRole(data['role'] ?? 'player') : AppRole.player,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp?)?.toDate() : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp?)?.toDate() : DateTime.now(),
      points: (data['points'] ?? 0) is num ? (data['points'] as num).toInt() : 0,
      orderCount: (data['orderCount'] ?? 0) is num ? (data['orderCount'] as num).toInt() : 0,
      deviceToken: data['deviceToken'] ?? '',
      isEmailVerified: data['isEmailVerified'] ?? false,
      isProfileActive: data['isProfileActive'] ?? false,
      reviewedProducts: data['reviewedProducts'] != null ? List<String>.from(data['reviewedProducts']) : null,
      verificationStatus: data.containsKey('verificationStatus')
          ? _mapVerificationStringToEnum(data['verificationStatus'] ?? '')
          : VerificationStatus.pending,
    );
  }

  static AppRole _parseRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'admin': return AppRole.admin;
      case 'partner': return AppRole.partner;
      case 'player':
      default: return AppRole.player;
    }
  }

  static VerificationStatus _mapVerificationStringToEnum(String verification) {
    switch (verification) {
      case 'pending': return VerificationStatus.pending;
      case 'approved': return VerificationStatus.approved;
      case 'rejected': return VerificationStatus.rejected;
      case 'submitted': return VerificationStatus.submitted;
      case 'underReview': return VerificationStatus.underReview;
      default: return VerificationStatus.unknown;
    }
  }
}