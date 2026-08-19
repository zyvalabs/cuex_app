import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/match_creation_controller.dart';
import '../../../core/utils/constants/app_colors.dart';
import '../../../core/widgets/cards/platform_options_card.dart';
import '../../../core/widgets/step/step_widget.dart';
import '../../../core/widgets/title/section_title_widget.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../rtmp/rtmp_screen.dart';
import '../youtube/youtube_setup_screen.dart';

/// Thin screen — just layout. Tapping a card sets streamPlatform on the
/// controller (so createMatch() later knows which path to take) and
/// navigates to that platform's setup screen.
class StreamingPlatformScreen extends StatelessWidget {
  const StreamingPlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchCreationController>();
    // ignore: avoid_print
    print('🟠 [StreamingPlatformScreen] build() called, current streamPlatform=${controller.streamPlatform.value}');

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StepWidget(totalSteps: 4, currentStep: 3),
            ),
            const SizedBox(height: 24),
            const SectionTitleWidget(
              title: 'Choose Streaming Platform',
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: PlatformOptionCard(
                      icon: Icons.play_circle_fill,
                      onTap: () {
                        controller.selectStreamPlatform('YouTube');
                        // ignore: avoid_print

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const YoutubeSetupScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PlatformOptionCard(
                      icon: Icons.settings_input_antenna,
                      onTap: () {
                        controller.selectStreamPlatform('RTMP');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RtmpSetupScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}