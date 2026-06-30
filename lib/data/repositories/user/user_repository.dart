import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../features/personalization/models/user_model.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../authentication/authentication_repository.dart';

/// Repository class for user-related operations.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;


  /// Function to save user data to Firestore.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  /// Fetch user by ID
  Future<UserModel> fetchUserById(String userId) async {
    try {
      final documentSnapshot = await _db.collection("Users").doc(userId).get();
      if (documentSnapshot.exists) {
        return UserModel.fromDocSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  Future<void> updateSingleFieldForUser(String userId, Map<String, dynamic> json) async {
    try {
      await _db.collection('Users').doc(userId).update(json);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  Future<List<UserModel>> fetchUsersByRole(AppRole? role) async {
    try {
      Query query = _db.collection('Users');
      if (role != null) query = query.where('role', isEqualTo: role.name);
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => UserModel.fromQuerySnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  /// Fetch multiple users by IDs
  Future<List<UserModel>> fetchMultipleUsers(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final users = await Future.wait(
          userIds.map((id) => fetchUserById(id))
      );
      return users;
    } catch (e) {
      throw 'Error fetching users: $e';
    }
  }
  /// Function to fetch user details based on user ID.
  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db.collection("Users").doc(AuthenticationRepository.instance.getUserID).get();
      print('🔴 fetchUserDetails — userId: ${AuthenticationRepository.instance.getUserID}');
      print('🔴 fetchUserDetails — exists: ${documentSnapshot.exists}');
      if (documentSnapshot.exists) {
        return UserModel.fromDocSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      print('🔴 fetchUserDetails Firebase error: ${e.code} — ${e.message}');
      throw TFirebaseException(e.code).message;
    } catch (e, stack) {
      print('🔴 fetchUserDetails unknown error: $e');
      print('🔴 Stack: $stack');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to update user data in Firestore.
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db.collection("Users").doc(updatedUser.id).update(updatedUser.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update any field in specific Users Collection
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db.collection("Users").doc(AuthenticationRepository.instance.getUserID).update(json);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Upload any Image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = _firebaseStorage.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to remove user data from Firestore.
  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  // In UserRepository, add this:
  Future<UserModel?> findUserByPhone(String phoneNumber) async {
    try {
      final snapshot = await _db
          .collection("Users")
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return UserModel.fromQuerySnapshot(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> findUserByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection("Users")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return UserModel.fromQuerySnapshot(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }
// In your UserRepository, add this function:
  Future<String> createUnregisteredUser({
    required String firstName,
    required String lastName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    try {
      // Check if user exists by phone
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final existingUser = await findUserByPhone(phoneNumber);
        if (existingUser != null) {
          throw 'User with phone number $phoneNumber already exists';
        }
      }

      // Check by email
      if (email != null && email.isNotEmpty) {
        final existingUser = await findUserByEmail(email);
        if (existingUser != null) {
          throw 'User with email $email already exists';
        }
      }

      // Generate a unique ID for unregistered user
      final docRef = _db.collection("Users").doc();

      final newUser = UserModel(
        id: docRef.id,
        firstName: firstName,
        lastName: lastName,
        userName: UserModel.generateUsername('$firstName $lastName'),
        email: email ?? '',
        phoneNumber: phoneNumber ?? '',
        profilePicture: profilePicture ?? '',
        role: AppRole.player,
        isEmailVerified: false,
        isProfileActive: false,
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newUser.toJson());
      print('USER CREATED: ${docRef.id}'); // Debug
      return docRef.id;

    } on FirebaseException catch (e) {
      print('FIREBASE ERROR: ${e.message}'); // Debug
      throw TFirebaseException(e.code).message;
    } catch (e) {
      print('GENERAL ERROR: $e'); // Debug
      rethrow;
    }
  }
  /// Function to fetch Admin from Firestore.
  Future<UserModel> fetchAdmin(String role) async {
    try {
      final querySnapshot  = await _db.collection("Users").where("role", isEqualTo: role).get();
      if (querySnapshot .docs.isNotEmpty) {
        return UserModel.fromQuerySnapshot(querySnapshot.docs.first);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}