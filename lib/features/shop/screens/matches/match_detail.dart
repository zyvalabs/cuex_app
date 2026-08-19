import 'package:cuex_app/features/shop/screens/matches/widgets/frame_stats_widget.dart';
import 'package:cuex_app/features/shop/screens/matches/widgets/head_to_head_widget.dart';
import 'package:cuex_app/features/shop/screens/matches/widgets/match_info_widget.dart';
import 'package:cuex_app/features/shop/screens/matches/widgets/match_mea_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/appbar/tabbar.dart';
import '../../../../common/widgets/matches/card/match_card.dart';
import '../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../common/widgets/youtube/match_youtube_player.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/helpers/match_card_helper.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/match_stat_controller.dart';
import '../../controllers/matches_controller.dart';
import '../../models/match_model.dart';
import '../live_scroring/widgets/match_options_menu.dart';
import '../players/widgets/season_tab.dart';
import 'match_qr_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({super.key, required this.match});
  final MatchModel match;

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late final MatchStatsController matchStatsController;

  // ✅ cache future — no shimmer flash on rebuild
  late final Future<Map<String, dynamic>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    matchStatsController =
        Get.put(MatchStatsController(), tag: widget.match.id);
    matchStatsController.watchMatchFrames(widget.match.id);
    MatchController.instance.watchMatch(widget.match.id);
    _detailsFuture = MatchDataHelper.getMatchDetails(widget.match);
  }

  @override
  void dispose() {
    matchStatsController.stopWatchingFrames();
    MatchController.instance.stopWatchingMatch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserController.instance.user.value;
    final showQR = currentUser.role == AppRole.admin ||
        widget.match.createdBy == currentUser.id ||
        widget.match.player1Id == currentUser.id;

    debugPrint('🔍 currentUser: ${currentUser.id} role: ${currentUser.role}');
    debugPrint('🔍 match.createdBy: ${widget.match.createdBy}');
    debugPrint('🔍 match.player1Id: ${widget.match.player1Id}');
    debugPrint('🔍 showQR: $showQR');
    final dark = THelperFunctions.isDarkMode(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final hasVideo = widget.match.youtubeLink != null &&
        widget.match.youtubeLink!.isNotEmpty;

    // ── Landscape — video only ────────────
    if (isLandscape && hasVideo) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 72,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                'Video Coming Soon',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Portrait ──────────────────────────
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: TColors.peppercorn,
        appBar: TAppBar(
          showBackArrow: true,
          title: const Text('Match Details'),
          showActions: true,
          showSkipButton: false,
          actions: [
            // ✅ QR only for creator/admin
            if (showQR)
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => MatchQRCodeScreen(match: widget.match),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: const Icon(
                    Iconsax.scan_barcode,
                    size: 17,
                    color: Colors.white70,
                  ),
                ),
              ),

            // More options
            GestureDetector(
              onTap: () => MatchOptionsMenu.show(context, widget.match),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: const Icon(
                  Iconsax.more,
                  size: 17,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),

        body: FutureBuilder<Map<String, dynamic>>(
          future: _detailsFuture, // ✅ cached
          builder: (context, snapshot) {
            // ── Shimmer ────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _MatchDetailShimmer();
            }

            // ── Error ──────────────────────
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.warning_2,
                        size: 28,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load match details',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Please try again',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;

            return NestedScrollView(
              headerSliverBuilder: (_, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // ── Video player ────────────

                          if (hasVideo)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Video Coming Soon',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                        // ── Match metadata ──────────
                        MatchMetadata(
                          player1Name: data['player1Name'] ?? 'Player 1',
                          player2Name: data['player2Name'] ?? 'Player 2',
                          tournamentName:
                          data['tournamentName'] ?? 'Tournament',
                          roundName: data['roundName'] ?? 'Round',
                          date: DateFormat('MMM dd, yyyy')
                              .format(widget.match.scheduledTime),
                        ),

                        // ── Match card ──────────────
                        MatchCard(
                          match: widget.match,
                          matchStatsController: matchStatsController,
                          showHeader: false,
                          showBorder: false,
                          animateOnOpen: true,
                        ),
                        const SizedBox(height: TSizes.md),
                      ],
                    ),
                  ),

                  // ── Tab bar ─────────────────
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    toolbarHeight: 0,
                    collapsedHeight: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor:
                    dark ? Colors.black : TColors.white,
                    bottom: const TTabBar(
                      tabs: [
                        Tab(child: Text('Frame Stats')),
                        Tab(child: Text('Match')),
                        Tab(child: Text('History')),
                        Tab(child: Text('Season')),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _buildFrameStatsTab(),
                  MatchInfoWidget(
                    match: widget.match,
                    player1Name: data['player1Name'] ?? '',
                    player2Name: data['player2Name'] ?? '',
                    tournamentName: data['tournamentName'] ?? '',
                    roundName: data['roundName'] ?? '',
                  ),
                  HeadToHeadWidget(
                    match: widget.match,
                    player1Name: data['player1Name'] ?? '',
                    player2Name: data['player2Name'] ?? '',
                  ),
                  SeasonStatsWidget(
                    match: widget.match,
                    player1Name: data['player1Name'] ?? '',
                    player2Name: data['player2Name'] ?? '',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrameStatsTab() {
    return Obx(() {
      final frames = matchStatsController.frames;

      if (frames.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.chart,
                  size: 28,
                  color: Colors.white24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No Frames Yet',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Frame stats will appear once the match starts',
                style: TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: frames.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.white.withOpacity(0.06),
        ),
        itemBuilder: (context, index) =>
            FrameStatsWidget(frame: frames[index]),
      );
    });
  }
}

// ─────────────────────────────────────────────
// Match Detail Shimmer
// ─────────────────────────────────────────────

class _MatchDetailShimmer extends StatelessWidget {
  const _MatchDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Video placeholder
          Container(
            width: double.infinity,
            height: 200,
            color: const Color(0xFF111111),
            child: Center(
              child: Icon(
                Iconsax.video_play,
                size: 40,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Metadata shimmer
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      TShimmerEffect(
                          width: 160, height: 13, radius: 4),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          TShimmerEffect(
                              width: 80, height: 13, radius: 4),
                          TShimmerEffect(
                              width: 80, height: 13, radius: 4),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Match card shimmer
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          TShimmerEffect(
                              width: 48, height: 48, radius: 24),
                          const SizedBox(height: 6),
                          TShimmerEffect(
                              width: 60, height: 10, radius: 4),
                        ],
                      ),
                      const Spacer(),
                      TShimmerEffect(
                          width: 60, height: 32, radius: 8),
                      const Spacer(),
                      Column(
                        children: [
                          TShimmerEffect(
                              width: 48, height: 48, radius: 24),
                          const SizedBox(height: 6),
                          TShimmerEffect(
                              width: 60, height: 10, radius: 4),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tab placeholder
                TShimmerEffect(
                  width: double.infinity,
                  height: 44,
                  radius: 10,
                ),
                const SizedBox(height: 16),

                // Frame stats shimmer rows
                ...List.generate(
                  4,
                      (_) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        TShimmerEffect(
                            width: 32, height: 32, radius: 4),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              TShimmerEffect(
                                  width: 100, height: 12, radius: 4),
                              const SizedBox(height: 5),
                              TShimmerEffect(
                                  width: 70, height: 10, radius: 4),
                            ],
                          ),
                        ),
                        TShimmerEffect(
                            width: 40, height: 24, radius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}