import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../add_particpant.dart';

/// Header row shown when embedded in EventDetailScreen
class ParticipantsHeader extends StatelessWidget {
  const ParticipantsHeader({
    required this.eventId,
    required this.count,
    required this.onAdded,
  });

  final String eventId;
  final int count;
  final VoidCallback onAdded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          TSizes.defaultSpace, 12, TSizes.defaultSpace, 0),
      child: Row(
        children: [
          Text(
            '$count Participants',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await Get.to(() => const AddParticipantScreen(),
                  arguments: eventId);
              onAdded();
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: TColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.user_add, size: 14, color: TColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Add',
                    style: TextStyle(
                        fontSize: 12,
                        color: TColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}