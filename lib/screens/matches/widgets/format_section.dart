import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/match_creation_controller.dart';
import '../../../core/widgets/selector/option_selector_widget.dart';
import '../../../core/widgets/step/number_stepper_widget.dart';

/// Sport-specific format section — swaps content based on selected sport:
/// Snooker -> Best of Frames + Number of Reds
/// Pool -> Race to Frames + Game Type (8-Ball/9-Ball)
/// Heyball -> Race to Frames only
/// Billiards -> Race to Points only
class FormatSection extends StatelessWidget {
  const FormatSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchCreationController>();

    return Obx(() {
      final sportName = controller.selectedSport.value.name;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.showsFramesStepper) ...[
            NumberStepperWidget(
              label: sportName == 'Snooker' ? 'Best of Frames' : 'Race to Frames',
              value: controller.bestOfFrames.value,
              onChanged: (val) => controller.bestOfFrames.value = val,
            ),
            const SizedBox(height: 24),
          ],
          _buildSportSpecificField(controller, sportName),
        ],
      );
    });
  }

  Widget _buildSportSpecificField(MatchCreationController controller, String sportName) {
    switch (sportName) {
      case 'Snooker':
        return OptionSelectorWidget(
          title: 'Number of Reds',
          options: const ['15', '10', '6'],
          selectedOption: controller.selectedFormatValue.value,
          onSelected: (val) => controller.selectedFormatValue.value = val,
        );

      case 'Pool':
        return OptionSelectorWidget(
          title: 'Game Type',
          options: const ['8-Ball', '9-Ball'],
          selectedOption: controller.selectedFormatValue.value,
          onSelected: (val) => controller.selectedFormatValue.value = val,
        );

      case 'Billiards':
        return NumberStepperWidget(
          label: 'Race to Points',
          value: controller.bestOfFrames.value, // reused as points value
          minValue: 10,
          maxValue: 500,
          step: 10,
          onChanged: (val) => controller.bestOfFrames.value = val,
        );

      case 'Heyball':
      default:
        return const SizedBox.shrink(); // nothing extra — frames stepper above covers it
    }
  }
}