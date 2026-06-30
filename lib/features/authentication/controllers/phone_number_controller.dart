import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/services/notifications/notification_service.dart';
import '../../../routes/routes.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/formatters/formatter.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../../personalization/models/user_model.dart';

class SignInController extends GetxController {
  static SignInController get instance => Get.isRegistered()
      ? Get.find()
      : Get.put(SignInController());

  final localStorage = GetStorage();
  final phone = TextEditingController();

  // ✅ Default India +91
  final selectedCountryCode = RxString('+91');

  GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    phone.text = localStorage.read('REMEMBER_ME_PHONE') ?? '';
    super.onInit();
  }

  @override
  void onClose() {
    phone.dispose();
    super.onClose();
  }

  // ── Login with phone number ───────────────
  Future<void> loginWithPhoneNumber() async {
    try {
      // Validate country code
      if (selectedCountryCode.value.isEmpty) {
        TLoaders.warningSnackBar(
          title: 'Select Country',
          message: 'Please select your country code.',
        );
        return;
      }

      // Validate form
      if (signInFormKey.currentState == null) return;
      if (!signInFormKey.currentState!.validate()) return;

      // Check internet
      if (!await _checkInternetConnectivity()) return;

      // Show loader
      TFullScreenLoader.openLoadingDialog(
        'Sending verification code...',
        TImages.docerAnimation,
      );

      // Format number
      final formattedPhone = TFormatter.formatPhoneNumberWithCountryCode(
        selectedCountryCode.value,
        phone.text.trim(),
      );

      // Send OTP
      await AuthenticationRepository.instance.loginWithPhoneNo(formattedPhone);

      // Stop loader before navigating
      TFullScreenLoader.stopLoading();

      // Navigate to OTP screen
      final result = await Get.toNamed(
        TRoutes.otpVerification,
        parameters: {
          'phoneNumberWithCountryCode': formattedPhone,
          'phoneNumber': phone.text.trim(),
        },
      );

      // ✅ null-safe bool check
      final otpVerified = result == true;

      if (otpVerified) {
        TFullScreenLoader.openLoadingDialog(
          'Setting up your account...',
          TImages.docerAnimation,
        );

        // Fetch or register user
        await UserController.instance.fetchUserRecord();
        if (UserController.instance.user.value.id.isEmpty) {
          await _registerNewUser(formattedPhone);
        }

        TFullScreenLoader.stopLoading();

        TLoaders.successSnackBar(
          title: 'Verified!',
          message: 'Welcome to CueX 🎱',
        );

        // Redirect
        await AuthenticationRepository.instance
            .screenRedirect(FirebaseAuth.instance.currentUser);
      }
    } on FirebaseAuthException catch (e) {
      TFullScreenLoader.stopLoading();
      _handleFirebaseError(e);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      debugPrint('🔴 loginWithPhoneNumber error: $e');
      TLoaders.errorSnackBar(
        title: 'Something went wrong',
        message: 'Please try again.',
      );
    }
  }

  // ── Internet check ────────────────────────
  Future<bool> _checkInternetConnectivity() async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
        title: 'No Internet',
        message: 'Please check your connection and try again.',
      );
      return false;
    }
    return true;
  }

  // ── Register new user ─────────────────────
  Future<void> _registerNewUser(String phoneNumber) async {
    try {
      final token = await TNotificationService.getToken();
      final newUser = UserModel(
        id: AuthenticationRepository.instance.getUserID,
        firstName: '',
        lastName: '',
        userName: '',
        email: '',
        phoneNumber: phoneNumber,
        profilePicture: '',
        deviceToken: token,
        isEmailVerified: false,
        isProfileActive: false,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
        role: AppRole.player,
        verificationStatus: VerificationStatus.approved,
      );
      await UserController.instance.saveUserRecord(user: newUser);
    } catch (e) {
      debugPrint('🔴 registerNewUser error: $e');
    }
  }

  // ── Firebase error handler ─────────────────
  void _handleFirebaseError(FirebaseAuthException e) {
    debugPrint('🔴 FirebaseAuthException: ${e.code} — ${e.message}');

    String message;
    switch (e.code) {
      case 'invalid-phone-number':
        message = 'The phone number entered is invalid. Please check and try again.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please wait a few minutes and try again.';
        break;
      case 'missing-client-identifier':
        message = 'Verification failed. Please try again.';
        break;
      case 'quota-exceeded':
        message = 'SMS quota exceeded. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection.';
        break;
      case 'session-expired':
        message = 'OTP expired. Please request a new one.';
        break;
      case 'invalid-verification-code':
        message = 'Incorrect OTP. Please try again.';
        break;
      case 'operation-not-allowed':
        message = 'Phone sign-in is not enabled. Please contact support.';
        break;
      default:
        message = 'Verification failed. Please try again.';
    }

    TLoaders.errorSnackBar(title: 'Oops!', message: message);
  }
}