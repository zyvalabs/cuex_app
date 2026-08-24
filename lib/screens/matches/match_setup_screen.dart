import 'package:cuex_app/controllers/match_setup_controller.dart';
import 'package:cuex_app/screens/matches/widgets/format_section.dart';
import 'package:cuex_app/screens/matches/widgets/match_setup_section.dart';
import 'package:cuex_app/screens/matches/widgets/player_fields_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/match_creation_controller.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../core/widgets/step/step_widget.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../events/widgets/round_name_section.dart';
import '../stream/streaming/streaming_platform_screen.dart';

/// Thin screen — just layout, stacking pre-built sections.
/// All state and validation logic lives on MatchCreationController.
class MatchSetupScreen extends StatelessWidget {
  const MatchSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchSetupController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'New Match',
        showBackButton: true,
        rightActions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => AppButton(
          text: 'Next',
          onPressed: controller.isMatchSetupValid
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StreamingPlatformScreen()),
            );
          }
              : null,
        )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const StepWidget(totalSteps: 4, currentStep: 2),
                const SizedBox(height: 24),

                const MatchTypeSection(),
                const SizedBox(height: 24),

                const FormatSection(),
                const SizedBox(height: 24),

                const PlayerFieldsSection(),

                // Round Name only shows when this match is linked to an event
                Obx(() => controller.isLinkedToEvent
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(height: 24),
                    RoundNameSection(),
                  ],
                )
                    : const SizedBox.shrink()),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}