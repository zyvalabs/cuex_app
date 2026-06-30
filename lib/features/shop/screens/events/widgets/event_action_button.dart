import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../controllers/matches_controller.dart';
import '../../../models/event_model.dart';
import '../../matches/create_match_screen.dart';

class EventActionButton extends StatelessWidget {
  const EventActionButton({super.key, required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: ElevatedButton.icon(
        onPressed: () {
          if (!Get.isRegistered<MatchController>()) {
            Get.put(MatchController());
          }
          Get.to(() => CreateMatchScreen(
            eventId: event.id,
            prefilledSportId: event.sportId,
            isPractice: false,
          ));
        },
        icon: const Icon(Iconsax.add, color: Colors.white, size: 18),
        label: const Text('Create Match', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: TColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}