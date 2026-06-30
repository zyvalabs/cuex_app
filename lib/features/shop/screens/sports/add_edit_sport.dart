import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/colors.dart';
import '../../controllers/sport_controller.dart';
import '../../models/sport_model.dart';


class AddEditSportScreen extends StatefulWidget {
  const AddEditSportScreen({super.key, this.sport});
  final SportModel? sport;

  bool get isEdit => sport != null;

  @override
  State<AddEditSportScreen> createState() => _AddEditSportScreenState();
}

class _AddEditSportScreenState extends State<AddEditSportScreen> {
  late final SportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SportController>()
        ? Get.find<SportController>()
        : Get.put(SportController());

    if (widget.isEdit) {
      controller.prefill(widget.sport!);
    } else {
      controller.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text(
          widget.isEdit ? 'Edit Sport' : 'Add Sport',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Sport name
            _SectionLabel(label: 'Sport Name *'),
            const SizedBox(height: TSizes.spaceBtwItems),
            TextFormField(
              controller: controller.nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Snooker, Billiards, Pool',
                prefixIcon: Icon(Iconsax.cup, size: 18),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Description
            _SectionLabel(label: 'Description (optional)'),
            const SizedBox(height: TSizes.spaceBtwItems),
            TextFormField(
              controller: controller.descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Short description of the sport',
                prefixIcon: Icon(Iconsax.text, size: 18),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Icon section
            _SectionLabel(label: 'Sport Icon (optional)'),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Toggle — upload vs URL
            Obx(() => Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                      controller.useUrlInstead.value = false,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !controller.useUrlInstead.value
                              ? Colors.red
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Upload Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: !controller.useUrlInstead.value
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: !controller.useUrlInstead.value
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                      controller.useUrlInstead.value = true,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: controller.useUrlInstead.value
                              ? Colors.red
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Paste URL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: controller.useUrlInstead.value
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: controller.useUrlInstead.value
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Image picker or URL input
            Obx(() => controller.useUrlInstead.value
                ? TextFormField(
              controller: controller.iconUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Icon URL',
                hintText: 'https://example.com/icon.png',
                prefixIcon: Icon(Iconsax.global, size: 18),
              ),
            )
                : GestureDetector(
              onTap: controller.pickImage,
              child: Obx(() {
                final hasPicked =
                    controller.pickedImage.value != null;
                final hasExisting =
                    controller.existingIconUrl.value.isNotEmpty;

                return Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08)),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: hasPicked
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        controller.pickedImage.value!,
                        fit: BoxFit.cover,
                      ),
                      Container(color: Colors.black38),
                      const Center(
                        child: Icon(Iconsax.camera,
                            color: Colors.white, size: 24),
                      ),
                    ],
                  )
                      : hasExisting
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        controller.existingIconUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholder(),
                      ),
                      Container(color: Colors.black38),
                      const Center(
                        child: Icon(Iconsax.camera,
                            color: Colors.white,
                            size: 24),
                      ),
                    ],
                  )
                      : _placeholder(),
                );
              }),
            )),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Order
            _SectionLabel(label: 'Display Order'),
            const SizedBox(height: TSizes.spaceBtwItems),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Text(
                    'Order: ${controller.order.value + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (controller.order.value > 0) {
                        controller.order.value--;
                      }
                    },
                    icon: const Icon(Iconsax.minus,
                        size: 18, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () => controller.order.value++,
                    icon: const Icon(Iconsax.add,
                        size: 18, color: Colors.grey),
                  ),
                ],
              ),
            )),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Toggles
            _SectionLabel(label: 'Visibility'),
            const SizedBox(height: TSizes.spaceBtwItems),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border:
                Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  Obx(() => _ToggleTile(
                    icon: Iconsax.eye,
                    iconColor: Colors.green,
                    title: 'Active',
                    subtitle: 'Show in app',
                    value: controller.isActive.value,
                    onChanged: (val) =>
                    controller.isActive.value = val,
                  )),
                  Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.05)),
                  Obx(() => _ToggleTile(
                    icon: Iconsax.star,
                    iconColor: const Color(0xFFD4A843),
                    title: 'Featured',
                    subtitle: 'Show on home screen',
                    value: controller.isFeatured.value,
                    onChanged: (val) =>
                    controller.isFeatured.value = val,
                  )),
                  Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.05)),
                  Obx(() => _ToggleTile(
                    icon: Iconsax.code,
                    iconColor: Colors.orange,
                    title: 'Testing',
                    subtitle: 'Hide from players/partners',
                    value: controller.isTesting.value,
                    onChanged: (val) =>
                    controller.isTesting.value = val,
                  )),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Submit
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => widget.isEdit
                    ? controller.updateSport(
                    widget.sport!, context)
                    : controller.addSport(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: Colors.red,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  widget.isEdit ? 'Update Sport' : 'Add Sport',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            )),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Iconsax.image, size: 32, color: Colors.grey),
        const SizedBox(height: 8),
        Text('Tap to upload icon',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
          ),
        ],
      ),
    );
  }
}