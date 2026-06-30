import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../data/repositories/events/event_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/constants/colors.dart';
import '../../controllers/live_updates_controller.dart';
import '../../controllers/match_stat_controller.dart';
import '../../controllers/matches_controller.dart';
import '../../models/match_model.dart';
import '../matches/match_qr_screen.dart';
import '../matches/widgets/match_score_header.dart';
import 'widgets/frame_history_list.dart';
import 'widgets/match_options_menu.dart';

import 'widgets/scoring_bottom_sheet.dart';

class LiveScoringScreen extends StatefulWidget {
  const LiveScoringScreen({super.key, required this.match});
  final MatchModel match;

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen> {
  late final MatchStatsController matchStatsController;
  late Future<Map<String, dynamic>> _matchDetailsFuture;
  final _sheetController = DraggableScrollableController();

  String _player1Name = '';
  String _player2Name = '';

  static const double _maxSize = 0.60;

  @override
  void initState() {
    super.initState();
    Get.put(LiveUpdatesController());
    matchStatsController = Get.put(MatchStatsController());
    matchStatsController.watchMatchFrames(widget.match.id);
    MatchController.instance.watchMatch(widget.match.id);
    _matchDetailsFuture = _getMatchDetails();
  }

  @override
  void dispose() {
    matchStatsController.stopWatchingFrames();
    MatchController.instance.stopWatchingMatch();
    _sheetController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getMatchDetails() async {
    try {
      final event = await EventRepository.instance.fetchSingleItem(widget.match.eventId);
      final player1 = await UserRepository.instance.fetchUserById(widget.match.player1Id!);
      final player2 = await UserRepository.instance.fetchUserById(widget.match.player2Id!);

      if (mounted) {
        setState(() {
          _player1Name = player1.firstName;
          _player2Name = player2.firstName;
        });
      }

      return {
        'tournamentName': event.name,
        'player1Name': player1.firstName,
        'player2Name': player2.firstName,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: const Text('Live Scoring'),
        showActions: true,
        showSkipButton: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.scan_barcode),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => MatchQRCodeScreen(match: widget.match),
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.more),
            onPressed: () => MatchOptionsMenu.show(context, widget.match),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _matchDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.red));
              }
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: MatchScoreHeader(match: widget.match)),
                  const FrameHistoryList(),
                  SliverToBoxAdapter(child: SizedBox(height: screenHeight * _maxSize + 40)),
                ],
              );
            },
          ),
          ScoringBottomSheet(
            match: widget.match,
            player1Name: _player1Name,
            player2Name: _player2Name,
            sheetController: _sheetController,
            matchStatsController: matchStatsController,
          ),
        ],
      ),
    );
  }
}