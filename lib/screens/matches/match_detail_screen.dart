import 'package:cuex_app/screens/matches/widgets/delete_match_dialog.dart';
import 'package:cuex_app/screens/matches/widgets/match_summary_card.dart';
import 'package:cuex_app/screens/matches/widgets/stream_ingest_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/match_creation_controller.dart';
import '../../core/model/match_model.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';


/// Thin screen — resolves data once at the top (from a passed-in MatchModel,
/// or live from MatchCreationController if just created), then just stacks
/// pre-built sections. No inline dialogs or builder methods.
class MatchDetailsScreen extends StatelessWidget {
  final MatchModel? match;

  const MatchDetailsScreen({super.key, this.match});

  @override
  Widget build(BuildContext context) {
    // Resolve everything to plain values ONCE, regardless of data source.
    if (match != null) {
      return _buildContent(
        context: context,
        sport: match!.sport,
        matchType: match!.matchType,
        format: match!.format.isNotEmpty
            ? '${match!.format} · Best of ${match!.bestOfFrames}'
            : 'Best of ${match!.bestOfFrames}',
        playerNames: match!.playerNames,
        youtubeLink: match!.streamPlatform == 'YouTube' && match!.youtubeBroadcastId != null
            ? 'https://www.youtube.com/watch?v=${match!.youtubeBroadcastId}'
            : null,
        rtmpUrl: match!.streamPlatform == 'RTMP' ? match!.rtmpUrl : null,
        streamKey: match!.streamPlatform == 'RTMP' ? match!.streamKey : null,
        showDelete: true,
      );
    }

    final controller = Get.find<MatchCreationController>();

    return Obx(() => _buildContent(
      context: context,
      sport: controller.selectedSport.value.name,
      matchType: controller.selectedMatchType.value ?? '',
      format: controller.needsFormatSelector
          ? '${controller.selectedFormatValue.value} · Best of ${controller.bestOfFrames.value}'
          : 'Best of ${controller.bestOfFrames.value}',
      playerNames: controller.playerControllers
          .take(controller.playerFieldCount)
          .map((c) => c.text.trim())
          .toList(),
      youtubeLink: controller.streamPlatform.value == 'YouTube' &&
          controller.createdYoutubeBroadcastId.value != null
          ? 'https://www.youtube.com/watch?v=${controller.createdYoutubeBroadcastId.value}'
          : null,
      rtmpUrl: controller.streamPlatform.value == 'RTMP' ? controller.rtmpUrl.value : null,
      streamKey: controller.streamPlatform.value == 'RTMP' ? controller.streamKey.value : null,
      showDelete: false,
    ));
  }

  Widget _buildContent({
    required BuildContext context,
    required String sport,
    required String matchType,
    required String format,
    required List<String> playerNames,
    String? youtubeLink,
    String? rtmpUrl,
    String? streamKey,
    required bool showDelete,
  }) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: showDelete ? 'Match Details' : 'Match Created',
        showBackButton: showDelete,
        rightActions: showDelete
            ? [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => showDeleteMatchDialog(context, match!.id!),
          ),
        ]
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MatchSummaryCard(sport: sport, matchType: matchType, format: format, playerNames: playerNames),
              const SizedBox(height: 20),
              StreamIngestCard(youtubeLink: youtubeLink, rtmpUrl: rtmpUrl, streamKey: streamKey),
              const Spacer(),
              AppButton(text: 'Go Live', onPressed: () {}),
              const SizedBox(height: 12),
              AppButton(
                text: 'Go to My Matches',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}