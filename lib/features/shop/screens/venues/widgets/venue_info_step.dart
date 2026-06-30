import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../controllers/add_venue_controller.dart';


class VenueInfoStep extends StatelessWidget {
  const VenueInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AddEditVenueController.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: c.nameController,
            decoration: const InputDecoration(
              labelText: 'Venue Name *',
              hintText: 'e.g. Cue Royale Snooker Club',
              prefixIcon: Icon(Iconsax.building, size: 18),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: c.descriptionController,
            maxLines: 4,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Tell players about your venue...',
              prefixIcon: Icon(Iconsax.document_text, size: 18),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: c.phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+91 98765 43210',
              prefixIcon: Icon(Iconsax.call, size: 18),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: c.websiteController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Website',
              hintText: 'https://yourvenuewebsite.com',
              prefixIcon: Icon(Iconsax.global, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}