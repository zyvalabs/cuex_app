import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/match_creation_controller.dart';
import '../../../../core/widgets/radio/radio_option.dart';


/// Public / Unlisted / Private — full UI inline, wired to controller.
class YoutubeVisibilitySection extends StatelessWidget {
  const YoutubeVisibilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchCreationController>();

    return Obx(() {
      final selected = controller.youtubeVisibility.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Visibility', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          RadioOptionTile(
            title: 'Public',
            subtitle: 'Anyone can search for and view',
            isSelected: selected == 'Public',
            onTap: () => controller.setYoutubeVisibility('Public'),
          ),
          RadioOptionTile(
            title: 'Unlisted',
            subtitle: 'Anyone with the link can view',
            isSelected: selected == 'Unlisted',
            onTap: () => controller.setYoutubeVisibility('Unlisted'),
          ),
          RadioOptionTile(
            title: 'Private',
            subtitle: 'Only people you choose can view',
            isSelected: selected == 'Private',
            onTap: () => controller.setYoutubeVisibility('Private'),
          ),
        ],
      );
    });
  }
}