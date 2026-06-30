import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/colors.dart';

import '../../controllers/promotion_controller.dart';
import '../../models/promotion_model.dart';
import 'widgets/promo_image_picker.dart';
import 'widgets/promo_link_selector.dart';
import 'widgets/promo_type_toggle.dart';

class AddEditPromoScreen extends StatefulWidget {
  const AddEditPromoScreen({super.key, this.promo});
  final PromotionModel? promo;

  bool get isEdit => promo != null;

  @override
  State<AddEditPromoScreen> createState() => _AddEditPromoScreenState();
}

class _AddEditPromoScreenState extends State<AddEditPromoScreen> {
  late final PromotionController controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PromotionController>()
        ? Get.find<PromotionController>()
        : Get.put(PromotionController());

    if (widget.isEdit) {
      controller.prefill(widget.promo!);
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
          widget.isEdit ? 'Edit Promotion' : 'Add Promotion',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Type toggle
              _SectionLabel(label: 'Promo Type'),
              const SizedBox(height: TSizes.spaceBtwItems),
              PromoTypeToggle(
                selected: controller.selectedType,
                onChanged: (val) => controller.selectedType.value = val,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Image picker — only for image type
              Obx(() => controller.selectedType.value == 'image'
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: 'Promo Image *'),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  PromoImagePicker(
                    pickedImage: controller.pickedImage,
                    existingImageUrl: controller.existingImageUrl,
                    onPick: controller.pickImage,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              )
                  : const SizedBox.shrink()),

              // Video URL — only for video type
              Obx(() => controller.selectedType.value == 'video'
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: 'Video URL *'),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TextFormField(
                    controller: controller.videoUrlController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'YouTube / Video URL',
                      hintText: 'https://youtube.com/watch?v=...',
                      prefixIcon:
                      Icon(Iconsax.video, size: 18),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              )
                  : const SizedBox.shrink()),

              // Title
              _SectionLabel(label: 'Promo Title *'),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                controller: controller.titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. World Snooker Championship 2024',
                  prefixIcon: Icon(Iconsax.text, size: 18),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Button title
              _SectionLabel(label: 'Button Title *'),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                controller: controller.buttonTitleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Button Text',
                  hintText: 'e.g. Explore Now, Register Now',
                  prefixIcon: Icon(Iconsax.mouse, size: 18),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Link selector
              _SectionLabel(label: 'Tap Destination'),
              const SizedBox(height: TSizes.spaceBtwItems),
              PromoLinkSelector(
                selectedLinkType: controller.selectedLinkType,
                selectedLinkRoute: controller.selectedLinkRoute,
                externalUrlController: controller.externalUrlController,
                onLinkTypeChanged: (val) =>
                controller.selectedLinkType.value = val,
                onRouteChanged: (val) =>
                controller.selectedLinkRoute.value = val,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Order
              _SectionLabel(label: 'Display Order'),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order: ${controller.order.value}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    children: [
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
                ],
              )),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Active toggle
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.md, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius:
                  BorderRadius.circular(TSizes.cardRadiusMd),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.eye, size: 18, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Active',
                              style:
                              TextStyle(color: Colors.white, fontSize: 14)),
                          Text(
                            controller.isActive.value
                                ? 'Visible on home screen'
                                : 'Hidden from home screen',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: controller.isActive.value,
                      onChanged: (val) =>
                      controller.isActive.value = val,
                      activeColor: Colors.red,
                    ),
                  ],
                ),
              )),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Submit button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => widget.isEdit
                      ? controller.updatePromo(
                      widget.promo!, context)
                      : controller.addPromo(context),
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
                    widget.isEdit
                        ? 'Update Promotion'
                        : 'Add Promotion',
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
      ),
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