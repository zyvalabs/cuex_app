import 'package:cuex_app/screens/matches/widgets/stream_ingest_card.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/buttons/app_button.dart';
import '../../../core/utils/constants/app_colors.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../live streaming/go_live_camera_screen.dart';
import 'delete_match_dialog.dart';
import 'match_summary_card.dart';


/// Pure layout — takes already-resolved plain values, no data-source logic.
/// MatchDetailsScreen's only job is deciding WHERE these values come from
/// (a passed-in MatchModel vs the live MatchCreationController), then
/// handing them to this widget to actually render.
class MatchDetailsView extends StatelessWidget {
  final String sport;
  final String matchType;
  final String format;
  final List<String> playerNames;
  final String? youtubeLink;
  final String? rtmpUrl;
  final String? streamKey;
  final bool showDelete;
  final String? matchId; // required when showDelete is true

  const MatchDetailsView({
    super.key,
    required this.sport,
    required this.matchType,
    required this.format,
    required this.playerNames,
    this.youtubeLink,
    this.rtmpUrl,
    this.streamKey,
    required this.showDelete,
    this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: showDelete ? 'Match Details' : 'Match Created',
        showBackButton: showDelete,
        rightActions: showDelete && matchId != null
            ? [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => showDeleteMatchDialog(context, matchId!),
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
                        side1Players: playerNames.length >= 2 ? [playerNames[0]] : playerNames,
                        side2Players: playerNames.length >= 2 ? [playerNames[1]] : const [],
                        rtmpUrl: rtmpUrl,
                        streamKey: streamKey,
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