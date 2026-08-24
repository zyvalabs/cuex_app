import 'package:cuex_app/screens/stream/youtube/widgets/youtube_channel_section.dart';
import 'package:cuex_app/screens/stream/youtube/widgets/youtube_metadata_section.dart';
import 'package:cuex_app/screens/stream/youtube/widgets/youtube_schedule_sectiond.dart';
import 'package:cuex_app/screens/stream/youtube/widgets/youtube_thumbnail_section.dart';
import 'package:cuex_app/screens/stream/youtube/widgets/youtube_visibility_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/buttons/app_button.dart';
import '../../../controllers/match_creation_controller.dart';
import '../../../controllers/youtube_setup_controller.dart';
import '../../../core/utils/constants/app_colors.dart';
import '../../../core/widgets/step/step_widget.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../matches/match_detail_screen.dart';

/// Thin screen — just layout, stacking pre-built sections.
/// YoutubeSetupController holds connection/metadata state;
/// MatchCreationController orchestrates the final createMatch() call.
class YoutubeSetupScreen extends StatefulWidget {
  const YoutubeSetupScreen({super.key});

  @override
  State<YoutubeSetupScreen> createState() => _YoutubeSetupScreenState();
}

class _YoutubeSetupScreenState extends State<YoutubeSetupScreen> {
  final youtubeController = Get.isRegistered<YoutubeSetupController>()
      ? Get.find<YoutubeSetupController>()
      : Get.put(YoutubeSetupController());

  final matchCreationController = Get.find<MatchCreationController>();

  @override
  void initState() {
    super.initState();
    // Check if user already has YouTube connected from a previous session,
    // so they don't have to log in again every time.
    youtubeController.loadExistingYoutubeConnection();
  }

  @override
  Widget build(BuildContext context) {
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
          text: matchCreationController.isSaving.value ? 'Creating Match...' : 'Create Match',
          isLoading: matchCreationController.isSaving.value,
          onPressed: youtubeController.isYoutubeConnected.value && !matchCreationController.isSaving.value
              ? () async {
            final matchId = await matchCreationController.createMatch();

            if (matchId != null) {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MatchDetailsScreen(freshlyCreatedMatchId: matchId)),
                );
              }
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(matchCreationController.saveError.value ?? 'Failed to create match')),
              );
            }
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
                const StepWidget(totalSteps: 4, currentStep: 4),
                const SizedBox(height: 24),

                const YoutubeConnectionSection(),

                Obx(() => youtubeController.isYoutubeConnected.value
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(height: 20),
                    YoutubeMetadataSection(),
                    SizedBox(height: 20),
                    YoutubeThumbnailSection(),
                    SizedBox(height: 20),
                    YoutubeVisibilitySection(),
                    SizedBox(height: 20),
                    YoutubeScheduleSection(),
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