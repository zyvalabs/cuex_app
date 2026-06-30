import 'package:cuex_app/features/shop/screens/home/widgets/app_footer.dart';
import 'package:cuex_app/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:cuex_app/features/shop/screens/streaming/widgets/go_live_teaser.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/header/section_header.dart';
import '../../../../common/widgets/shimmers/horitonal_shimmer.dart';
import '../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/high_break.dart';
import '../../controllers/live_updates_controller.dart';
import '../../controllers/matches_controller.dart';
import '../../controllers/match_stat_controller.dart';
import '../../controllers/news_controller.dart';
import '../events/widgets/event_card_vertical.dart';
import '../highest break/leaderboard_screen.dart';
import '../highest break/widgets/top_breaks_podium.dart';
import '../matches/matches_screen.dart';
import '../matches/widgets/horizontal_match_slider.dart';
import '../news/news_horizontal_screen.dart';
import '../news/news_list_screen.dart';
import '../../../../utils/constants/text_strings.dart';
import '../promotion/widgets/promo_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final EventController eventController;
  late final MatchController matchController;
  late final MatchStatsController matchStatsController;
  late final HighestBreaksController highestBreaksController;
  late final NewsController newsController;
  late final LiveUpdatesController liveUpdatesController;

  final _isRefreshing = false.obs;

  @override
  void initState() {
    super.initState();
    eventController = Get.isRegistered<EventController>()
        ? Get.find<EventController>()
        : Get.put(EventController());
    matchController = Get.isRegistered<MatchController>()
        ? Get.find<MatchController>()
        : Get.put(MatchController());
    matchStatsController = Get.isRegistered<MatchStatsController>()
        ? Get.find<MatchStatsController>()
        : Get.put(MatchStatsController());
    highestBreaksController = Get.isRegistered<HighestBreaksController>()
        ? Get.find<HighestBreaksController>()
        : Get.put(HighestBreaksController());
    newsController = Get.isRegistered<NewsController>()
        ? Get.find<NewsController>()
        : Get.put(NewsController());
    liveUpdatesController = Get.isRegistered<LiveUpdatesController>()
        ? Get.find<LiveUpdatesController>()
        : Get.put(LiveUpdatesController());
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      _isRefreshing.value = true;
      await Future.wait([
        matchController.fetchLiveMatches(),
        matchController.fetchUpcomingMatches(),
        eventController.fetchFeaturedEvents(),
        highestBreaksController.fetchTopBreaks(),
        newsController.fetchPublishedNews(),
      ]);
    } finally {
      _isRefreshing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: TColors.june,
        backgroundColor: const Color(0xFF1C1C1C),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App bar ───────────────────────────
            const SliverToBoxAdapter(child: THomeAppBar()),

            // ── Promo slider ──────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: TSizes.spaceBtwSections)),
            const SliverToBoxAdapter(child: PromoSlider()),
            const SliverToBoxAdapter(child: SizedBox(height: TSizes.spaceBtwSections)),

            // ── Body ──────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Live Matches ────────────────
                  SectionHeader(
                    title: TTexts.liveMatches,
                    onSeeAll: () => Get.to(() => const MatchesScreen(
                      initialTab: 0,
                      showBackArrow: true,
                    )),
                    isLive: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() => matchController.isLoading.value &&
                      matchController.liveMatches.isEmpty
                      ? const HorizontalShimmer()
                      : HorizontalMatchesSlider(
                    matches: RxList(matchController.liveMatches
                        .where((m) => m.matchType == 'tournament')
                        .toList()),
                    emptyMessage: 'No live matches right now',
                    emptyIcon: Iconsax.video_slash,
                    initialTab: 0,
                  )),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // ── Upcoming Matches ────────────
                  SectionHeader(
                    title: TTexts.upcomingMatches,
                    onSeeAll: () => Get.to(() => const MatchesScreen(
                      initialTab: 1,
                      showBackArrow: true,
                    )),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() => matchController.isLoading.value &&
                      matchController.upcomingMatches.isEmpty
                      ? const HorizontalShimmer()
                      : HorizontalMatchesSlider(
                    matches: RxList(matchController.upcomingMatches
                        .where((m) => m.matchType == 'tournament')
                        .toList()),
                    emptyMessage: 'No upcoming matches',
                    emptyIcon: Iconsax.calendar,
                    initialTab: 1,
                  )),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // ── Featured Events ─────────────
                  SectionHeader(
                    title: 'Featured Events',
                    onSeeAll: () => Get.toNamed(TRoutes.events),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() {
                    if (eventController.isLoading.value &&
                        eventController.featuredEvents.isEmpty) {
                      return const HorizontalShimmer();
                    }
                    if (eventController.featuredEvents.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return FeaturedEventsSection(
                      events: eventController.featuredEvents,
                    );
                  }),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // ── Highest Breaks ──────────────
                  SectionHeader(
                    title: 'Highest Breaks',
                    onSeeAll: () => Get.to(() => const LeaderboardScreen()),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const TopBreaksPodium(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // ── News & Updates ──────────────
                  SectionHeader(
                    title: 'News & Updates',
                    onSeeAll: () => Get.to(() => const NewsListScreen()),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() => newsController.isLoading.value &&
                      newsController.publishedNews.isEmpty
                      ? const HorizontalShimmer()
                      : const NewsVerticalList()),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // ── Footer ──────────────────────
                  AppFooter(),
                  SizedBox(
                    height: TDeviceUtils.getBottomNavigationBarHeight() +
                        TSizes.defaultSpace,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
