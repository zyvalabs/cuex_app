import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/event_creation_controller.dart';
import '../../../core/widgets/selector/option_selector_widget.dart';
import '../../../core/widgets/step/number_stepper_widget.dart';


/// Sport-specific format section for events — same pattern as FormatSection
/// used in match creation, but reads/writes EventCreationController instead.
class EventFormatSection extends StatelessWidget {
  const EventFormatSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventCreationController>();

    return Obx(() {
      final sportName = controller.selectedSport.value.name;

      // Note: unlike single-match creation, events don't show a fixed
      // "Best of Frames" stepper here — frame count typically varies per
      // round in a tournament (e.g. best of 3 early rounds, best of 7 final),
      // so it doesn't make sense to lock it in at event-creation time.
      return _buildSportSpecificField(controller, sportName);
    });
  }

  Widget _buildSportSpecificField(EventCreationController controller, String sportName) {
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
          value: controller.bestOfFrames.value,
          minValue: 10,
          maxValue: 500,
          step: 10,
          onChanged: (val) => controller.bestOfFrames.value = val,
        );

      case 'Heyball':
      default:
        return const SizedBox.shrink();
    }
  }
}