import 'package:cuex_app/screens/matches/widgets/delete_match_dialog.dart';
import 'package:cuex_app/screens/matches/widgets/match_summary_card.dart';
import 'package:cuex_app/screens/matches/widgets/stream_ingest_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/match_creation_controller.dart';
import '../../controllers/match_setup_controller.dart';
import '../../controllers/rtmp_setup_controller.dart';
import '../../controllers/youtube_setup_controller.dart';
import '../../core/model/match_model.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../live streaming/go_live_camera_screen.dart';
import '../scoring/scoring_screen.dart';class MatchDetailsScreen extends StatelessWidget {
  final MatchModel? match;
  // Used only in the fresh-creation flow (match == null), since the
  // just-created matchId isn't part of a MatchModel object yet at that
  // point — passed directly by whichever screen called createMatch().
  final String? freshlyCreatedMatchId;

  const MatchDetailsScreen({super.key, this.match, this.freshlyCreatedMatchId});

  @override
  Widget build(BuildContext context) {
    // Resolve everything to plain values ONCE, regardless of data source.
    if (match != null) {
      return _buildContent(
        context: context,
        matchId: match!.id,
        sport: match!.sport,
        matchType: match!.matchType,
        format: match!.format.isNotEmpty
            ? '${match!.format} · Best of ${match!.bestOfFrames}'
            : 'Best of ${match!.bestOfFrames}',
        playerNames: match!.playerNames,
        teamNameA: match!.teamNameA,
        teamNameB: match!.teamNameB,
        youtubeLink: match!.streamPlatform == 'YouTube' && match!.youtubeBroadcastId != null
            ? 'https://www.youtube.com/watch?v=${match!.youtubeBroadcastId}'
            : null,
        rtmpUrl: match!.rtmpUrl,
        streamKey: match!.streamKey,
        showDelete: true,
      );
    }

    final matchSetup = Get.find<MatchSetupController>();
    final matchCreation = Get.find<MatchCreationController>();

    return Obx(() {
      String? youtubeLink;
      String? rtmpUrl;
      String? streamKey;

      if (matchCreation.streamPlatform.value == 'YouTube' && Get.isRegistered<YoutubeSetupController>()) {
        final youtube = Get.find<YoutubeSetupController>();
        if (youtube.createdYoutubeBroadcastId.value != null) {
          youtubeLink = 'https://www.youtube.com/watch?v=${youtube.createdYoutubeBroadcastId.value}';
        }
        rtmpUrl = youtube.createdRtmpUrl.value;
        streamKey = youtube.createdStreamKey.value;
      } else if (matchCreation.streamPlatform.value == 'RTMP' && Get.isRegistered<RtmpSetupController>()) {
        final rtmp = Get.find<RtmpSetupController>();
        rtmpUrl = rtmp.rtmpUrl.value;
        streamKey = rtmp.streamKey.value;
      }

      return _buildContent(
        context: context,
        matchId: freshlyCreatedMatchId,
        sport: matchSetup.selectedSport.value.name,
        matchType: matchSetup.selectedMatchType.value ?? '',
        format: matchSetup.needsFormatSelector
            ? '${matchSetup.selectedFormatValue.value} · Best of ${matchSetup.bestOfFrames.value}'
            : 'Best of ${matchSetup.bestOfFrames.value}',
        playerNames: matchSetup.playerControllers
            .take(matchSetup.playerFieldCount)
            .map((c) => c.text.trim())
            .toList(),
        teamNameA: matchSetup.teamNameAController.text.trim().isNotEmpty
            ? matchSetup.teamNameAController.text.trim()
            : null,
        teamNameB: matchSetup.teamNameBController.text.trim().isNotEmpty
            ? matchSetup.teamNameBController.text.trim()
            : null,
        youtubeLink: youtubeLink,
        rtmpUrl: rtmpUrl,
        streamKey: streamKey,
        showDelete: false,
      );
    });
  }

  Widget _buildContent({
    required BuildContext context,
    String? matchId,
    required String sport,
    required String matchType,
    required String format,
    required List<String> playerNames,
    String? teamNameA,
    String? teamNameB,
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
              AppButton(
                text: 'Go Live',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoLiveCameraScreen(
                        matchId: matchId,
                        sport: sport,
                        side1Players: matchType == 'Doubles'
                            ? playerNames.take(2).toList()
                            : [playerNames.isNotEmpty ? playerNames[0] : ''],
                        side2Players: matchType == 'Doubles'
                            ? playerNames.skip(2).take(2).toList()
                            : [playerNames.length > 1 ? playerNames[1] : ''],
                        teamNameA: teamNameA,
                        teamNameB: teamNameB,
                        rtmpUrl: rtmpUrl,
                        streamKey: streamKey,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              AppButton(
                text: 'Start Scoring',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoringScreen(
                        matchId: matchId,
                        sport: sport,
                        matchType: matchType,
                        side1Players: matchType == 'Doubles' ? playerNames.take(2).toList() : [playerNames.isNotEmpty ? playerNames[0] : ''],
                        side2Players: matchType == 'Doubles' ? playerNames.skip(2).take(2).toList() : [playerNames.length > 1 ? playerNames[1] : ''],
                        teamNameA: teamNameA,
                        teamNameB: teamNameB,
                      ),
                    ),
                  );
                },
              ),
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