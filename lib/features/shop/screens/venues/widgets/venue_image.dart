import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../controllers/add_venue_controller.dart';


class VenueImagesStep extends StatelessWidget {
  const VenueImagesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AddEditVenueController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Thumbnail
          Text('Main Image', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text('This is the primary image shown in venue cards', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(() {
            final hasPicked = c.pickedThumbnail.value != null;
            print('🖼️ Obx rebuild — hasPicked: $hasPicked path: ${c.pickedThumbnail.value?.path}');
            final hasExisting = c.thumbnailImage.value.isNotEmpty;
            return GestureDetector(
              onTap: () => c.pickThumbnail(context),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: hasPicked
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  child: Image.file(c.pickedThumbnail.value!, fit: BoxFit.cover),
                )
                    : hasExisting
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                      child: Image.network(c.thumbnailImage.value, fit: BoxFit.cover),
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
                          Text('Tap to change', style: TextStyle(color: Colors.white70)),
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
                    Text('Tap to upload main image', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('Recommended: 16:9 ratio', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Gallery
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gallery Images', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text('Additional photos of your venue', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
              TextButton.icon(
                onPressed: c.pickGalleryImages,
                icon: const Icon(Iconsax.add, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          Obx(() {
            final allImages = [
              ...c.pickedGalleryImages.map((f) => _ImageItem(file: f)),
              ...c.galleryImages.map((url) => _ImageItem(url: url)),
            ];

            if (allImages.isEmpty) {
              return Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Text('No gallery images added', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: allImages.length,
              itemBuilder: (_, i) {
                final item = allImages[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                      child: item.file != null
                          ? Image.file(item.file!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                          : Image.network(item.url!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => c.removeGalleryImage(i),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
          const SizedBox(height: TSizes.defaultSpace),
        ],
      ),
    );
  }
}

class _ImageItem {
  final File? file;
  final String? url;
  const _ImageItem({this.file, this.url});
}