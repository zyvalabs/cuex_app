import 'package:cuex_app/features/shop/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../home_menu.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/complete_profile_controller.dart';
import '../../controllers/user_controller.dart';

import 'widgets/profile_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.isCompleting = false});
  final bool isCompleting;

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final formController = Get.isRegistered<CompleteProfileController>()
        ? Get.find<CompleteProfileController>()
        : Get.put(CompleteProfileController());

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: !isCompleting,
        showSkipButton: false,
        showActions: false,
        title: Text(
          isCompleting ? 'Complete Profile' : 'Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Profile Picture
              Center(
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      return Stack(
                        children: [
                          controller.imageUploading.value
                              ? const TShimmerEffect(width: 100, height: 100, radius: 100)
                              : networkImage.isNotEmpty
                              ? CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white, // ✅
                            backgroundImage: NetworkImage(networkImage),
                          )
                              : Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: TColors.white, width: 2),
                              color: TColors.primary.withOpacity(0.05),
                            ),
                            child: const Icon(Iconsax.camera, size: 32, color: TColors.primary),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => controller.uploadUserProfilePicture(),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Iconsax.camera, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    Obx(() => GestureDetector(
                      onTap: () => controller.uploadUserProfilePicture(),
                      child: Text(
                        controller.user.value.profilePicture.isNotEmpty ? 'Change Photo' : 'Add Photo',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Full Name
              TextFormField(
                controller: formController.fullNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Iconsax.user, size: 18),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              // Email or Phone
              Obx(() {
                final hasPhone = controller.user.value.phoneNumber.isNotEmpty;
                final hasEmail = controller.user.value.email.isNotEmpty;
                if (hasPhone && !hasEmail) {
                  return Column(children: [
                    TextFormField(
                      controller: formController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: Icon(Iconsax.sms, size: 18),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                  ]);
                } else if (hasEmail && !hasPhone) {
                  return Column(children: [
                    TextFormField(
                      controller: formController.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: Icon(Iconsax.call, size: 18),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                  ]);
                }
                return const SizedBox.shrink();
              }),

              // Gender
              Obx(() => DropdownButtonFormField<String>(
                value: formController.selectedGender.value.isNotEmpty ? formController.selectedGender.value : null,
                decoration: const InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: Icon(Iconsax.user_edit, size: 18),
                ),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => formController.selectedGender.value = val ?? '',
              )),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              // DOB
              Obx(() => GestureDetector(
                onTap: () => formController.pickDob(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: formController.selectedDob.value != null
                          ? TColors.primary
                          : Colors.grey.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 18,
                        color: formController.selectedDob.value != null ? TColors.primary : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formController.selectedDob.value != null
                            ? DateFormat('dd MMM yyyy').format(formController.selectedDob.value!)
                            : 'Date of Birth *',
                        style: TextStyle(
                          color: formController.selectedDob.value != null
                              ? null
                              : Colors.grey.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              // City
              TextFormField(
                controller: formController.cityController,
                decoration: const InputDecoration(
                  labelText: 'City (Optional)',
                  prefixIcon: Icon(Iconsax.location, size: 18),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Read-only info in non-completing mode
              if (!isCompleting) ...[
                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),
                TProfileMenu(onPressed: () {}, title: 'E-mail', value: controller.user.value.email),
                TProfileMenu(onPressed: () {}, title: 'Phone Number', value: controller.user.value.phoneNumber),
                const SizedBox(height: TSizes.spaceBtwItems),
              ],

              // Save Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: formController.isLoading.value
                      ? null
                      : () => formController.saveProfile(context, isCompleting: isCompleting),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: formController.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isCompleting ? 'Complete Profile' : 'Save Changes'),
                ),
              )),
              // ADD HERE
              if (isCompleting) ...[
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      GetStorage().write('profile_completion_skipped', true);
                      Get.offAll(() => const HomeScreen());
                    },
                    child: const Text('Skip for now'),
                  ),
                ),
              ],
              const SizedBox(height: TSizes.defaultSpace),
            ],
          ),
        ),
      ),
    );
  }
}