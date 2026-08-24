import 'package:cuex_app/controllers/match_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/match_creation_controller.dart';
import '../../../core/model/match_type.dart';
import '../../../core/widgets/selector/option_selector_widget.dart';


/// Match Type section — Solo / Singles / Doubles, options depend on selected sport.
/// Reads/writes directly to MatchCreationController — no local state.
class MatchTypeSection extends StatelessWidget {
  const MatchTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchSetupController>();

    return Obx(() {
      final sportName = controller.selectedSport.value.name;
      final matchTypes = kMatchTypesBySport[sportName] ?? [];

      return OptionSelectorWidget(
        title: 'Match Type',
        options: matchTypes.map((t) => t.name).toList(),
        selectedOption: controller.selectedMatchType.value,
        onSelected: (val) => controller.selectedMatchType.value = val,
      );
    });
  }
}