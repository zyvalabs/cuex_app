import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/event_controller.dart';

class EventImagePicker extends StatelessWidget {
  const EventImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final c = EventController.instance;
    return Obx(() {
      final hasPickedImage = c.pickedImage.value != null;
      final existingUrl = c.existingImageUrl.value;
      final hasExistingImage = existingUrl.isNotEmpty;

      return GestureDetector(
        onTap: c.pickImage,
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: hasPickedImage
              ? ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            child: Image.file(c.pickedImage.value!, fit: BoxFit.cover),
          )
              : hasExistingImage
              ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                child: Image.network(existingUrl, fit: BoxFit.cover),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.camera, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text('Tap to change image', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          )
              : const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.image, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tap to upload image', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text('Recommended: 16:9 ratio', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      );
    });
  }
}