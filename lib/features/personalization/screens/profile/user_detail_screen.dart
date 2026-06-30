import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../shop/controllers/user_list_controller.dart';
import '../../../shop/screens/users/widgets/role_badge.dart';
import '../../../shop/screens/users/widgets/user_avatar_widget.dart';
import '../../../shop/screens/users/widgets/verification_badge.dart';
import '../../models/user_model.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key, required this.userId});
  final String userId;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late final AdminUserController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AdminUserController>()
        ? Get.find<AdminUserController>()
        : Get.put(AdminUserController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserDetail(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEdit = controller.isEditMode.value;
      return Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Edit User' : 'User Detail'),
          actions: [
            Obx(() => controller.isLoading.value
                ? const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            )
                : IconButton(
              icon: Icon(isEdit ? Iconsax.close_circle : Iconsax.edit),
              onPressed: () => controller.toggleEditMode(),
            )),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          final user = controller.selectedUser.value;
          if (user == null) return const Center(child: Text('User not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Profile Header
                Center(
                  child: Column(
                    children: [
                      UserAvatarWidget(imageUrl: user.profilePicture, fullName: user.fullName, radius: 40),
                      const SizedBox(height: 12),
                      Text(user.fullName.isNotEmpty ? user.fullName : 'No Name', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RoleBadge(role: user.role),
                          const SizedBox(width: 8),
                          VerificationBadge(status: user.verificationStatus),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),

                isEdit ? _buildEditForm(context) : _buildViewMode(context, user),

                const SizedBox(height: TSizes.spaceBtwSections),
                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Delete button always visible
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Iconsax.trash, color: Colors.red, size: 18),
                    label: const Text('Delete User', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),
              ],
            ),
          );
        }),
        bottomNavigationBar: isEdit
            ? Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : () => controller.saveUserProfile(context),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: controller.isSaving.value
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save Changes'),
          )),
        )
            : null,
      );
    });
  }

  Widget _buildViewMode(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile Info', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.spaceBtwItems),
        _infoRow(context, Iconsax.sms, 'Email', user.email.isNotEmpty ? user.email : '—'),
        _infoRow(context, Iconsax.call, 'Phone', user.phoneNumber.isNotEmpty ? user.phoneNumber : '—'),
        _infoRow(context, Iconsax.location, 'City', user.city.isNotEmpty ? user.city : '—'),
        _infoRow(context, Iconsax.user, 'Gender', user.gender.isNotEmpty ? user.gender : '—'),
        _infoRow(context, Iconsax.calendar, 'DOB', user.dob != null ? DateFormat('dd MMM yyyy').format(user.dob!) : '—'),
        _infoRow(context, Iconsax.clock, 'Joined', user.createdAt != null ? DateFormat('dd MMM yyyy').format(user.createdAt!) : '—'),
        const SizedBox(height: TSizes.spaceBtwSections),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text('Admin Controls', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.spaceBtwItems),
        _controlRow(context,
          label: 'Role',
          child: Obx(() => DropdownButton<AppRole>(
            value: controller.selectedUser.value?.role ?? user.role,
            underline: const SizedBox.shrink(),
            items: AppRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
            onChanged: (val) { if (val != null) controller.updateUserRole(user.id, val); },
          )),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        _controlRow(context,
          label: 'Verification',
          child: Obx(() => DropdownButton<VerificationStatus>(
            value: controller.selectedUser.value?.verificationStatus ?? user.verificationStatus,
            underline: const SizedBox.shrink(),
            items: VerificationStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
            onChanged: (val) { if (val != null) controller.updateVerificationStatus(user.id, val); },
          )),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          ),
          child: SwitchListTile(
            title: const Text('Active Account'),
            subtitle: const Text('Deactivate to block user access'),
            value: controller.selectedUser.value?.isProfileActive ?? user.isProfileActive,
            onChanged: (val) => controller.toggleUserActive(user.id, val),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.cardRadiusMd)),
          ),
        )),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Edit Profile', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.spaceBtwItems),
        TextFormField(
          controller: controller.firstNameController,
          decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Iconsax.user, size: 18)),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        TextFormField(
          controller: controller.lastNameController,
          decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Iconsax.user, size: 18)),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        TextFormField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Iconsax.call, size: 18)),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        TextFormField(
          controller: controller.cityController,
          decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Iconsax.location, size: 18)),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedGender.value.isNotEmpty ? controller.selectedGender.value : null,
          decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Iconsax.user_edit, size: 18)),
          items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) => controller.selectedGender.value = val ?? '',
        )),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        Obx(() => GestureDetector(
          onTap: () => controller.pickDob(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar, size: 18, color: controller.selectedDob.value != null ? Theme.of(context).primaryColor : Colors.grey),
                const SizedBox(width: 12),
                Text(
                  controller.selectedDob.value != null
                      ? DateFormat('dd MMM yyyy').format(controller.selectedDob.value!)
                      : 'Date of Birth',
                  style: TextStyle(color: controller.selectedDob.value != null ? null : Colors.grey, fontSize: 14),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
          ),
        )),
        const SizedBox(height: TSizes.spaceBtwSections),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text('Admin Controls', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(() => DropdownButtonFormField<AppRole>(
          value: controller.selectedRole.value,
          decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Iconsax.shield_tick, size: 18)),
          items: AppRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
          onChanged: (val) => controller.selectedRole.value = val,
        )),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        Obx(() => DropdownButtonFormField<VerificationStatus>(
          value: controller.selectedVerification.value,
          decoration: const InputDecoration(labelText: 'Verification Status', prefixIcon: Icon(Iconsax.verify, size: 18)),
          items: VerificationStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (val) => controller.selectedVerification.value = val,
        )),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          ),
          child: SwitchListTile(
            title: const Text('Active Account'),
            subtitle: const Text('Deactivate to block user access'),
            value: controller.isActive.value,
            onChanged: (val) => controller.isActive.value = val,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.cardRadiusMd)),
          ),
        )),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _controlRow(BuildContext context, {required String label, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        child,
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to permanently delete this user? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.adminDeleteUser(controller.selectedUser.value!.id, context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}