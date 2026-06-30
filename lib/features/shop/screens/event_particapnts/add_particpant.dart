import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/event_registration_controller.dart';

class AddParticipantScreen extends StatelessWidget {
  const AddParticipantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String eventId = Get.arguments.toString();
    final controller = EventParticipantController.instance;
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final Rx<XFile?> selectedImage = Rx<XFile?>(null);
    final isSubmitting = false.obs;

    Future<void> pickImage() async {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );
      if (image != null) selectedImage.value = image;
    }

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Add Participant'),
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Profile Image
                Obx(() => GestureDetector(
                  onTap: pickImage,
                  child: selectedImage.value == null
                      ? const TCircularImage(image: TImages.user, width: 80, height: 80)
                      : CircleAvatar(
                    radius: 40,
                    backgroundImage: FileImage(File(selectedImage.value!.path)),
                  ),
                )),
                TextButton(onPressed: pickImage, child: const Text('Upload Photo')),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Full Name
                TextFormField(
                  controller: fullNameController,
                  validator: (value) => TValidator.validateEmptyText('Full Name', value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Full Name',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Email (Optional)
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      return TValidator.validateEmail(value);
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.direct),
                    labelText: 'Email (Optional)',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Phone Number (Optional)
                TextFormField(
                  controller: phoneController,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      return TValidator.validatePhoneNumber(value);
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: 'Phone Number (Optional)',
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => ElevatedButton(
          onPressed: isSubmitting.value
              ? null
              : () async {
            if (formKey.currentState!.validate()) {
              isSubmitting.value = true;
              try {
                final parts = fullNameController.text.trim().split(' ');
                final firstName = parts.first;
                final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

                await controller.addUnregisteredParticipant(
                  eventId: eventId,
                  firstName: firstName,
                  lastName: lastName,
                  email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  profileImage: selectedImage.value,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Participant added successfully'), backgroundColor: Colors.green),
                );

                await Future.delayed(const Duration(milliseconds: 500));
                Navigator.of(context).pop();
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(e.toString()),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                  ),
                );
              } finally {
                isSubmitting.value = false;
              }
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: TColors.primary,
          ),
          child: isSubmitting.value
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : const Text('Add Participant'),
        )),
      ),
    );
  }
}