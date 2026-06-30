
// ─────────────────────────────────────────────
// leaderboard_screen.dart
// ─────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../controllers/high_break.dart';
import 'widgets/top_breaks_podium.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final HighestBreaksController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller = Get.isRegistered<HighestBreaksController>()
        ? Get.find<HighestBreaksController>()
        : Get.put(HighestBreaksController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text(
          'Top Breaks',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.defaultSpace,
              vertical: 6,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: TColors.june,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                dividerHeight: 0,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Events'),
                  Tab(text: 'Practice'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final loading = controller.isFetching.value;
        final evEmpty = controller.eventBreaks.isEmpty;
        final prEmpty = controller.practiceBreaks.isEmpty;

        if (loading && evEmpty && prEmpty) {
          return const _LeaderboardShimmer();
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _LeaderboardList(
              breaks: controller.eventBreaks
                  .where((b) => b.breakScore >= 50)
                  .take(50)
                  .toList(),
              emptyMessage: 'No event breaks above 50 yet',
              onRefresh: controller.fetchTopBreaks,
            ),
            _LeaderboardList(
              breaks: controller.practiceBreaks
                  .where((b) => b.breakScore >= 50)
                  .take(50)
                  .toList(),
              emptyMessage: 'No practice breaks above 50 yet',
              onRefresh: controller.fetchTopBreaks,
            ),
          ],
        );
      }),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({
    required this.breaks,
    required this.emptyMessage,
    required this.onRefresh,
  });

  final List<HighestBreakModel> breaks;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (breaks.isEmpty) {
      return _EmptyState(message: emptyMessage, onRefresh: onRefresh);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: TColors.june,
      backgroundColor: const Color(0xFF1C1C1C),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          TSizes.defaultSpace,
          TSizes.defaultSpace,
          TSizes.defaultSpace,
          100,
        ),
        itemCount: breaks.length,
        itemBuilder: (_, i) => BreakAccentCard(
          breakModel: breaks[i],
          rank: i + 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _LeaderboardShimmer extends StatelessWidget {
  const _LeaderboardShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: 8,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: i < 3 ? 68 : 60,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
                color: Colors.white.withOpacity(0.08), width: 3),
            top: BorderSide(
                color: Colors.white.withOpacity(0.05), width: 0.5),
            right: BorderSide(
                color: Colors.white.withOpacity(0.05), width: 0.5),
            bottom: BorderSide(
                color: Colors.white.withOpacity(0.05), width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              TShimmerEffect(width: 28, height: 18, radius: 4),
              const SizedBox(width: 10),
              TShimmerEffect(
                  width: i < 3 ? 42 : 36,
                  height: i < 3 ? 42 : 36,
                  radius: i < 3 ? 21 : 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TShimmerEffect(width: 110, height: 13, radius: 4),
                    const SizedBox(height: 5),
                    TShimmerEffect(width: 70, height: 10, radius: 4),
                  ],
                ),
              ),
              TShimmerEffect(width: 36, height: i < 3 ? 36 : 28, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: TColors.june.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.cup, size: 30,
                color: TColors.june.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing Here Yet',
            style: GoogleFonts.bebasNeue(
              fontSize: 22,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: Colors.white38),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.white.withOpacity(0.08)),
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
    );
  }
}