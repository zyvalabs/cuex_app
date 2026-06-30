import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class PromoImagePicker extends StatelessWidget {
  const PromoImagePicker({
    super.key,
    required this.pickedImage,
    required this.existingImageUrl,
    required this.onPick,
  });

  final Rxn<File> pickedImage;
  final RxString existingImageUrl;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasPicked = pickedImage.value != null;
      final hasExisting = existingImageUrl.value.isNotEmpty;

      return GestureDetector(
        onTap: onPick,
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          clipBehavior: Clip.hardEdge,
          child: hasPicked
              ? Stack(
            fit: StackFit.expand,
            children: [
              Image.file(pickedImage.value!, fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.camera, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Change',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          )
              : hasExisting
              ? Stack(
            fit: StackFit.expand,
            children: [
              Image.network(existingImageUrl.value,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder()),
              Container(color: Colors.black45),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.camera,
                        color: Colors.white, size: 28),
                    SizedBox(height: 6),
                    Text('Tap to change',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          )
              : _placeholder(),
        ),
      );
    });
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Iconsax.image, size: 40, color: Colors.grey),
        const SizedBox(height: 8),
        const Text('Tap to upload image',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text('PNG, JPG supported',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
      ],
    );
  }
}