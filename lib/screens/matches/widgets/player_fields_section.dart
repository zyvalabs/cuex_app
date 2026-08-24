import 'package:cuex_app/controllers/match_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/match_creation_controller.dart';
import 'divider.dart';
import 'side_entry_section.dart';

/// Player entry — grouped into Side A / Side B cards, with optional
/// team names. Solo shows just Side A (no "vs"). Singles shows 1 player
/// per side. Doubles shows 2 players per side.
class PlayerFieldsSection extends StatelessWidget {
  const PlayerFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchSetupController>();

    return Obx(() {
      final matchType = controller.selectedMatchType.value;

      if (matchType == 'Solo') {
        return SideEntrySection(
          sideLabel: 'Side A',
          teamNameController: controller.teamNameAController,
          playerControllers: [controller.playerControllers[0]],
          onAnyFieldChanged: (_) => controller.onPlayerFieldChanged(),
        );
      }

      if (matchType == 'Singles') {
        return Column(
          children: [
            SideEntrySection(
              sideLabel: '',
              teamNameController: controller.teamNameAController,
              playerControllers: [controller.playerControllers[0]],
              onAnyFieldChanged: (_) => controller.onPlayerFieldChanged(),
            ),
            const VsDivider(),
            SideEntrySection(
              sideLabel: '',
              teamNameController: controller.teamNameBController,
              playerControllers: [controller.playerControllers[1]],
              onAnyFieldChanged: (_) => controller.onPlayerFieldChanged(),
            ),
          ],
        );
      }

      if (matchType == 'Doubles') {
        return Column(
          children: [
            SideEntrySection(
              sideLabel: 'Side A',
              teamNameController: controller.teamNameAController,
              playerControllers: [controller.playerControllers[0], controller.playerControllers[1]],
              onAnyFieldChanged: (_) => controller.onPlayerFieldChanged(),
            ),
            const VsDivider(),
            SideEntrySection(
              sideLabel: 'Side B',
              teamNameController: controller.teamNameBController,
              playerControllers: [controller.playerControllers[2], controller.playerControllers[3]],
              onAnyFieldChanged: (_) => controller.onPlayerFieldChanged(),
            ),
          ],
        );
      }

      return const SizedBox.shrink(); // nothing selected yet
    });
  }
}