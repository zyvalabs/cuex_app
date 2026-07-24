import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuex_app/features/shop/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../features/authentication/screens/signup/verify_email.dart';
import '../../../features/authentication/screens/welcome/welcome_screen.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../features/personalization/screens/profile/profile.dart';
import '../../../features/shop/controllers/venue_controller.dart';
import '../../../home_menu.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../../../utils/popups/loaders.dart';
import '../user/user_repository.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  late final Rx<User?> _firebaseUser;
  var phoneNo = ''.obs;
  var phoneNoVerificationId = ''.obs;
  bool isPhoneAutoVerified = false;
  int? _resendToken;

  // ── Getters ───────────────────────────────
  User? get firebaseUser => _firebaseUser.value;
  String get getUserID => _firebaseUser.value?.uid ?? '';
  String get getUserEmail => _firebaseUser.value?.email ?? '';
  String get getDisplayName => _firebaseUser.value?.displayName ?? '';
  String get getPhoneNo => _firebaseUser.value?.phoneNumber ?? '';

  @override
  void onReady() {
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.userChanges());
    FlutterNativeSplash.remove();
    screenRedirect(_firebaseUser.value);
  }

  // ─────────────────────────────────────────
  // Screen Redirect
  // ─────────────────────────────────────────
  Future<void> screenRedirect(User? user) async {
    try {
      if (user == null) {
        Get.offAll(
              () => const WelcomeScreen(),
          transition: Transition.noTransition,
          duration: Duration.zero,
        );
        return;
      }

      await UserController.instance.fetchUserRecord();

      final userDoc = await _db.collection('Users').doc(user.uid).get();
      final role = userDoc.data()?['role'] ?? 'player';

      if (role == 'partner') {
        await Get.put(VenueController()).fetchPartnerVenue(user.uid);
      }

      if (!user.emailVerified && user.phoneNumber == null) {
        Get.offAll(
              () => VerifyEmailScreen(email: getUserEmail),
          transition: Transition.noTransition,
          duration: Duration.zero,
        );
        return;
      }

      await TLocalStorage.init(user.uid);

      final userModel = UserController.instance.user.value;
      final storage = GetStorage();
      final skipped = storage.read('profile_completion_skipped') ?? false;

      final isProfileComplete = userModel.firstName.isNotEmpty &&
          userModel.phoneNumber.isNotEmpty;

      if (!isProfileComplete && role == 'player' && !skipped) {
        Get.offAll(
              () => const ProfileScreen(isCompleting: true),
          transition: Transition.noTransition,
          duration: Duration.zero,
        );
        return;
      }

      Get.offAll(
            () => const HomeScreen(),
        transition: Transition.noTransition,
        duration: Duration.zero,
      );
    } catch (e, stack) {
      debugPrint('🔴 screenRedirect error: $e');
      FirebaseCrashlytics.instance.recordError(e, stack);
      Get.offAll(
            () => const WelcomeScreen(),
        transition: Transition.noTransition,
        duration: Duration.zero,
      );
    }
  }

  // ─────────────────────────────────────────
  // Email & Password
  // ─────────────────────────────────────────

  Future<UserCredential> loginWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> reAuthenticateWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // ─────────────────────────────────────────
  // Google Sign In
  // ─────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      // ✅ user cancelled picker
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw 'Google authentication failed. Please try again.';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      debugPrint('🔴 signInWithGoogle error: $e');
      rethrow; // ✅ rethrow so LoginController can handle it
    }
  }

  // ─────────────────────────────────────────
  // Phone Authentication
  // ─────────────────────────────────────────

  Future<void> loginWithPhoneNo(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        timeout: const Duration(minutes: 2),
        verificationFailed: (FirebaseAuthException e) async {
          debugPrint('🔴 verificationFailed code: ${e.code}');
          debugPrint('🔴 verificationFailed message: ${e.message}');
          debugPrint('🔴 verificationFailed details: ${e.toString()}');

          // log device info
          debugPrint('📱 Package: com.cuex_app');
          debugPrint('📱 Phone: ${phoneNumber}');
          await FirebaseCrashlytics.instance.recordError(e, e.stackTrace);

          String message;
          switch (e.code) {
            case 'too-many-requests':
              message = 'Too many attempts. Please wait a few minutes and try again.';
              break;
            case 'invalid-phone-number':
              message = 'The phone number is invalid. Please check and try again.';
              break;
            case 'missing-client-identifier':
              message = 'Verification failed. Please try again.';
              break;
            case 'network-request-failed':
              message = 'No internet connection. Please check and try again.';
              break;
            case 'operation-not-allowed':
              message = 'Phone sign-in is currently unavailable. Please try Google sign-in.';
              break;
            default:
              message = 'Could not send OTP. Please try again.';
          }

          TLoaders.warningSnackBar(title: 'Verification Failed', message: message);
        },

        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ codeSent — verificationId: $verificationId');
          debugPrint('✅ resendToken: $resendToken');
          phoneNoVerificationId.value = verificationId;
          _resendToken = resendToken;
        },

        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Auto verified');
          try {
            final result = await _auth.signInWithCredential(credential);
            isPhoneAutoVerified = result.user != null;
            if (isPhoneAutoVerified) {
              await screenRedirect(_auth.currentUser);
            }
          } catch (e) {
            debugPrint('🔴 verificationCompleted error: $e');
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱ codeAutoRetrievalTimeout');
          phoneNoVerificationId.value = verificationId;
        },
      );

      phoneNo.value = phoneNumber;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Could not send OTP. Please try again.';
    }
  }

  // ─────────────────────────────────────────
  // Verify OTP
  // ─────────────────────────────────────────

  Future<bool> verifyOTP(String otp, String phoneNumber) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: phoneNoVerificationId.value,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user != null;
    } on FirebaseAuthException catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Verification failed. Please try again.';
    } finally {
      // ✅ reset state after verify attempt
      phoneNo.value = '';
      phoneNoVerificationId.value = '';
      isPhoneAutoVerified = false;
      _resendToken = null;
    }
  }

  // ─────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      Get.offAll(
            () => const WelcomeScreen(),
        transition: Transition.noTransition,
        duration: Duration.zero,
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Could not log out. Please try again.';
    }
  }

  // ─────────────────────────────────────────
  // Delete Account
  // ─────────────────────────────────────────

  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Could not delete account. Please try again.';
    }
  }
}