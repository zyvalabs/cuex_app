import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';

import '../../../../home_menu.dart';
import '../../personalization/controllers/user_controller.dart';

class CompleteProfileController extends GetxController {
  static CompleteProfileController get instance => Get.find();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();

  final selectedGender = ''.obs;
  final selectedDob = Rxn<DateTime>();
  final isLoading = false.obs;

  final _userRepo = UserRepository.instance;

  @override
  void onInit() {
    _prefill();
    super.onInit();
  }

  void _prefill() {
    final user = UserController.instance.user.value;
    fullNameController.text = user.fullName.trim();
    emailController.text = user.email;
    phoneController.text = user.phoneNumber;
    cityController.text = user.city;
    selectedGender.value = user.gender;
    selectedDob.value = user.dob;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.onClose();
  }

  bool validate() {
    if (fullNameController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please enter your full name');
      return false;
    }
    if (selectedGender.value.isEmpty) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please select your gender');
      return false;
    }
    if (selectedDob.value == null) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please select your date of birth');
      return false;
    }
    return true;
  }

  Future<void> pickDob(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDob.value ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
    );
    if (date != null) selectedDob.value = date;
  }

  Future<void> saveProfile(BuildContext context, {bool isCompleting = false}) async {
    if (!validate()) return;
    try {
      isLoading.value = true;

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.customToast(message: 'No Internet Connection');
        return;
      }

      final currentUserId = UserController.instance.user.value.id;

      // Check phone duplicate
      if (phoneController.text.trim().isNotEmpty) {
        final existing = await _userRepo.findUserByPhone(phoneController.text.trim());
        if (existing != null && existing.id != currentUserId) {
          TLoaders.warningSnackBar(title: 'Already Used', message: 'This phone number is already registered');
          return;
        }
      }

      // Check email duplicate
      if (emailController.text.trim().isNotEmpty) {
        final existing = await _userRepo.findUserByEmail(emailController.text.trim());
        if (existing != null && existing.id != currentUserId) {
          TLoaders.warningSnackBar(title: 'Already Used', message: 'This email is already registered');
          return;
        }
      }

      final nameParts = fullNameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      final userName = UserController.instance.user.value.userName.isNotEmpty
          ? UserController.instance.user.value.userName
          : 'cuex_${firstName.toLowerCase()}${lastName.toLowerCase()}';

      final Map<String, dynamic> updates = {
        'firstName': firstName,
        'lastName': lastName,
        'userName': userName,
        'gender': selectedGender.value,
        'dob': selectedDob.value,
        'isProfileActive': true,
        'updatedAt': DateTime.now(),
      };

      if (cityController.text.trim().isNotEmpty) updates['city'] = cityController.text.trim();
      if (emailController.text.trim().isNotEmpty) updates['email'] = emailController.text.trim();
      if (phoneController.text.trim().isNotEmpty) updates['phoneNumber'] = phoneController.text.trim();

      await _userRepo.updateSingleField(updates);
      await UserController.instance.fetchUserRecord(fetchLatestRecord: true);

      // Reprefill observables so UI reflects latest
      _prefill();

      TLoaders.successSnackBar(
        title: isCompleting ? 'Profile Complete' : 'Profile Updated',
        message: isCompleting ? 'Welcome to CueX!' : 'Your profile has been updated',
      );

      if (isCompleting && context.mounted) Get.offAll(() => const HomeMenu());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}