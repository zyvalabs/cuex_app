import 'package:cuex_app/screens/matches/widgets/match_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/my_matches_controller.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../stream/stream_match_screen.dart';
import 'match_detail_screen.dart';


/// My Matches screen — Stream New Match button + list of past matches,
/// newest first. Each match reuses MatchSummaryCard, wrapped for tap-to-open.
class MyMatchesScreen extends StatelessWidget {
  const MyMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MyMatchesController>()
        ? Get.find<MyMatchesController>()
        : Get.put(MyMatchesController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'My Matches',
        showBackButton: true,
        rightActions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                text: 'Stream New Match',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StreamMatchScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.error.value != null) {
                    return Center(child: Text('Failed to load matches: ${controller.error.value}'));
                  }

                  if (controller.matches.isEmpty) {
                    return const Center(child: Text('No matches yet — stream your first one!'));
                  }

                  return ListView.separated(
                    itemCount: controller.matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final match = controller.matches[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: match)),
                          );
                        },
                        child: MatchSummaryCard(
                          sport: match.sport,
                          matchType: match.matchType,
                          format: match.format.isNotEmpty
                              ? '${match.format} · Best of ${match.bestOfFrames}'
                              : 'Best of ${match.bestOfFrames}',
                          playerNames: match.playerNames,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}