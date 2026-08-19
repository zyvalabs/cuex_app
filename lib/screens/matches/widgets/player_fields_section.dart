import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/match_creation_controller.dart';
import '../../stream/widgets/player_name_field.dart';

/// Player name fields — count auto-adjusts based on selected match type
/// (Solo = 1, Singles = 2, Doubles = 4). Controllers live on the
/// MatchCreationController so values persist across rebuilds/screens.
class PlayerFieldsSection extends StatelessWidget {
  const PlayerFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchCreationController>();

    return Obx(() {
      final count = controller.playerFieldCount;

      return Column(
        children: List.generate(count, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PlayerNameField(
              label: 'Player ${index + 1}',
              controller: controller.playerControllers[index],
              onChanged: (_) => controller.onPlayerFieldChanged(),
            ),
          );
        }),
      );
    });
  }
}