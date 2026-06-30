import 'package:cuex_app/features/shop/screens/matches/widgets/compact_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/matches/card/match_card.dart';
import '../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../common/widgets/tab bar/cuex_tab_bar.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/matches_controller.dart';
import '../../models/match_model.dart';
import 'widgets/match_type_filter.dart';

class MatchesScreen extends StatefulWidget {
  final String? eventId;
  final int initialTab;
  final bool showBackArrow;
  final String? playerId; // ✅ filter by player

  const MatchesScreen({
    super.key,
    this.eventId,
    this.initialTab = 0,
    this.showBackArrow = false,
    this.playerId,
  });

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late final MatchController matchController;
  late TabController _tabController;
  String _selectedType = 'tournament';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    matchController = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      matchController.fetchLiveMatches(),
      matchController.fetchUpcomingMatches(),
      matchController.fetchCompletedMatches(),
    ]);
  }

  void _onFilterChanged(String type) {
    setState(() => _selectedType = type);
  }

  List<MatchModel> _applyFilter(RxList matches) {
    var all = matches.cast<MatchModel>().toList();

    // ✅ filter by player if provided
    if (widget.playerId != null && widget.playerId!.isNotEmpty) {
      all = all.where((m) =>
      m.player1Id == widget.playerId ||
          m.player2Id == widget.playerId,
      ).toList();
    }

    if (_selectedType == 'tournament') {
      return all.where((m) => m.eventId.isNotEmpty).toList();
    } else if (_selectedType == 'practice') {
      return all.where((m) => m.eventId.isEmpty).toList();
    }
    return all;
  }

  void _onMatchTap(MatchModel match) {
    final role = UserController.instance.user.value.role;
    if (match.matchStatus == 'completed') {
      Get.toNamed(TRoutes.matchDetails, arguments: match);
    } else if (role == AppRole.admin || role == AppRole.partner) {
      Get.toNamed(TRoutes.liveScoring, arguments: match);
    } else {
      Get.toNamed(TRoutes.matchDetails, arguments: match);
    }
  }

  Widget _buildMatchList(RxList matches) {
    return Obx(() {
      // ── Shimmer ──────────────────────────
      if (matchController.isLoading.value) {
        return const _MatchShimmerList();
      }

      final filtered = _applyFilter(matches);

      // ── Empty ─────────────────────────────
      if (filtered.isEmpty) {
        return _EmptyState(onRefresh: _refresh);
      }

      // ── List ──────────────────────────────
      return RefreshIndicator(
        onRefresh: _refresh,
        color: TColors.june,
        backgroundColor: const Color(0xFF1C1C1C),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
          itemCount: filtered.length,
          itemBuilder: (_, index) {
            final match = filtered[index];
            return match.matchType == 'practice'
                ? CompactMatchCard(match: match)
                : MatchCard(
              match: match,
              onTap: () => _onMatchTap(match),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ hide appbar when used inside PlayerStatsScreen
    final isEmbedded = widget.playerId != null && !widget.showBackArrow;

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: isEmbedded
          ? null
          : TAppBar(
        showBackArrow: widget.showBackArrow,
        showActions: false,
        showSkipButton: false,
        title: Text(
          'Matches',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Column(
        children: [
          CueXTabBar(
            controller: _tabController,
            tabs: const ['Live', 'Upcoming', 'Completed'],
            liveTabIndex: 0,
            liveCount: matchController.liveMatches,
            toggle: isEmbedded
                ? null // ✅ hide filter toggle when embedded
                : MatchTypeFilter(
              selected: _selectedType,
              onChanged: _onFilterChanged,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMatchList(matchController.liveMatches),
                _buildMatchList(matchController.upcomingMatches),
                _buildMatchList(matchController.completedMatches),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer List
// ─────────────────────────────────────────────

class _MatchShimmerList extends StatelessWidget {
  const _MatchShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TShimmerEffect(width: 60, height: 20, radius: 10),
                TShimmerEffect(width: 80, height: 12, radius: 4),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TShimmerEffect(width: 36, height: 36, radius: 18),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TShimmerEffect(width: 100, height: 13, radius: 4),
                    const SizedBox(height: 5),
                    TShimmerEffect(width: 60, height: 10, radius: 4),
                  ],
                ),
                const Spacer(),
                TShimmerEffect(width: 40, height: 28, radius: 6),
                const SizedBox(width: 8),
                TShimmerEffect(width: 36, height: 36, radius: 18),
              ],
            ),
            const SizedBox(height: 12),
            TShimmerEffect(width: 140, height: 10, radius: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        children: [
          SizedBox(
            height: constraints.maxHeight * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.video_slash,
                    size: 30,
                    color: Colors.white24,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Matches Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Nothing here yet.\nPull down to refresh.',
                  style: TextStyle(fontSize: 12, color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: onRefresh,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.refresh, size: 14, color: TColors.june),
                        const SizedBox(width: 6),
                        Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: TColors.june,
                          ),
                        ),
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