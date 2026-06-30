import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../data/repositories/user/user_repository.dart';

import '../../../../../utils/popups/loaders.dart';
import '../../personalization/models/user_model.dart';

class AdminUserController extends GetxController {
  static AdminUserController get instance => Get.find();

  AdminUserController({this.roleFilter});
  final AppRole? roleFilter;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isEditMode = false.obs;
  final users = <UserModel>[].obs;
  final search = ''.obs;
  final selectedUser = Rxn<UserModel>();

  // Edit form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final selectedGender = ''.obs;
  final selectedDob = Rxn<DateTime>();
  final selectedRole = Rxn<AppRole>();
  final selectedVerification = Rxn<VerificationStatus>();
  final isActive = false.obs;

  List<UserModel> get filtered => users.where((u) {
    final q = search.value.toLowerCase();
    return u.fullName.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
  }).toList();

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.onClose();
  }

  void toggleEditMode() => isEditMode.value = !isEditMode.value;

  void _prefillEditForm(UserModel user) {
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    phoneController.text = user.phoneNumber;
    cityController.text = user.city;
    selectedGender.value = user.gender;
    selectedDob.value = user.dob;
    selectedRole.value = user.role;
    selectedVerification.value = user.verificationStatus;
    isActive.value = user.isProfileActive;
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final result = await UserRepository.instance.fetchUsersByRole(roleFilter);
      users.assignAll(result);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserDetail(String userId) async {
    try {
      isLoading.value = true;
      selectedUser.value = null;
      final user = await UserRepository.instance.fetchUserById(userId);
      selectedUser.value = user;
      _prefillEditForm(user);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUserProfile(BuildContext context) async {
    try {
      isSaving.value = true;
      final user = selectedUser.value;
      if (user == null) return;

      final updates = <String, dynamic>{
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'city': cityController.text.trim(),
        'gender': selectedGender.value,
        'role': selectedRole.value?.name ?? user.role.name,
        'verificationStatus': selectedVerification.value?.name ?? user.verificationStatus.name,
        'isProfileActive': isActive.value,
        'updatedAt': DateTime.now(),
      };

      if (selectedDob.value != null) updates['dob'] = selectedDob.value;

      await UserRepository.instance.updateSingleFieldForUser(user.id, updates);

      // Update local list
      _updateLocalUser(user.id, (u) {
        u.firstName = firstNameController.text.trim();
        u.lastName = lastNameController.text.trim();
        u.phoneNumber = phoneController.text.trim();
        u.city = cityController.text.trim();
        u.gender = selectedGender.value;
        u.dob = selectedDob.value;
        u.role = selectedRole.value ?? u.role;
        u.verificationStatus = selectedVerification.value ?? u.verificationStatus;
        u.isProfileActive = isActive.value;
        return u;
      });

      // Refresh selected user
      await fetchUserDetail(user.id);
      isEditMode.value = false;
      TLoaders.successSnackBar(title: 'Saved', message: 'User profile updated successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickDob(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDob.value ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (date != null) selectedDob.value = date;
  }

  Future<void> updateUserRole(String userId, AppRole role) async {
    try {
      await UserRepository.instance.updateSingleFieldForUser(userId, {'role': role.name});
      _updateLocalUser(userId, (u) => u..role = role);
      if (selectedUser.value?.id == userId) selectedUser.value = selectedUser.value!..role = role;
      TLoaders.successSnackBar(title: 'Updated', message: 'Role changed to ${role.name}');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> updateVerificationStatus(String userId, VerificationStatus status) async {
    try {
      await UserRepository.instance.updateSingleFieldForUser(userId, {'verificationStatus': status.name});
      _updateLocalUser(userId, (u) => u..verificationStatus = status);
      if (selectedUser.value?.id == userId) selectedUser.value = selectedUser.value!..verificationStatus = status;
      TLoaders.successSnackBar(title: 'Updated', message: 'Verification set to ${status.name}');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> toggleUserActive(String userId, bool active) async {
    try {
      await UserRepository.instance.updateSingleFieldForUser(userId, {'isProfileActive': active});
      _updateLocalUser(userId, (u) => u..isProfileActive = active);
      if (selectedUser.value?.id == userId) selectedUser.value = selectedUser.value!..isProfileActive = active;
      TLoaders.successSnackBar(title: 'Updated', message: active ? 'User activated' : 'User deactivated');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> adminDeleteUser(String userId, BuildContext context) async {
    try {
      isLoading.value = true;
      await UserRepository.instance.removeUserRecord(userId);
      users.removeWhere((u) => u.id == userId);
      TLoaders.successSnackBar(title: 'Deleted', message: 'User deleted successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => fetchUsers();

  void _updateLocalUser(String userId, UserModel Function(UserModel) updater) {
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) users[index] = updater(users[index]);
  }
}