
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../add_particpant.dart';

/// Add participant button — used in bottom nav and inline empty state
class AddParticipantButton extends StatelessWidget {
  const AddParticipantButton({
    required this.eventId,
    required this.onAdded,
    this.inline = false,
  });

  final String eventId;
  final VoidCallback onAdded;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    if (inline) {
      return ElevatedButton.icon(
        onPressed: () async {
          await Get.to(() => const AddParticipantScreen(),
              arguments: eventId);
          onAdded();
        },
        icon: const Icon(Iconsax.user_add, size: 16),
        label: const Text('Add Participant'),
        style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: ElevatedButton.icon(
        onPressed: () async {
          await Get.to(() => const AddParticipantScreen(),
              arguments: eventId);
          onAdded();
        },
        icon: const Icon(Iconsax.user_add, size: 18),
        label: const Text('Add Participant'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: TColors.june,
        ),
      ),
    );
  }
}