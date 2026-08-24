import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/match_creation_controller.dart';
import '../../controllers/match_setup_controller.dart';
import '../../core/model/sports_model.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../core/widgets/cards/sport_options_card.dart';
import '../../core/widgets/step/step_widget.dart';
import '../../core/widgets/title/section_title_widget.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../matches/match_setup_screen.dart';

class StreamMatchScreen extends StatelessWidget {
  const StreamMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // First screen in the wizard flow — registers ALL the sub-controllers
    // used across the flow (Get.put() only creates if not already registered).
    // Every other screen must use Get.find() only, never Get.put() again,
    // or state gets wiped on rebuild.
    final controller = Get.isRegistered<MatchSetupController>()
        ? Get.find<MatchSetupController>()
        : Get.put(MatchSetupController());

    if (!Get.isRegistered<MatchCreationController>()) {
      Get.put(MatchCreationController());
    }

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
        child: AppButton(
          text: 'Next',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MatchSetupScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: StepWidget(totalSteps: 4, currentStep: 1),
            ),
            const SizedBox(height: 24),
            const SectionTitleWidget(
              title: 'Choose Sport',
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kSports.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final sport = kSports[index];

                  return Obx(() => SportOptionCard(
                    sportName: sport.name,
                    imagePath: sport.imagePath,
                    isSelected: controller.isSelected(sport),
                    onTap: () => controller.selectSport(sport),
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}