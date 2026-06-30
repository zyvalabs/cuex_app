import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';

import '../../../../common/widgets/images/image_slider.dart';
import '../../../../common/widgets/tab bar/cuex_tab_bar.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/event_registration_controller.dart';
import '../../models/event_model.dart';
import '../event_draw/event_draw_screen.dart';
import '../event_particapnts/event_particapants_screen.dart';
import '../event_particapnts/widgets/particant_number_card.dart';
import '../players/widgets/event_venue.dart';
import '../players/widgets/event_winner.dart';
import 'widgets/event_action_button.dart';
import 'widgets/event_info_grid.dart';
import 'widgets/event_matches_widget.dart';
import 'widgets/event_prize_banner.dart';
import 'widgets/event_register_button.dart';
import 'widgets/event_status_badge.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.event});
  final EventModel event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late final EventParticipantController _participantController;
  late TabController _tabController;
  late List<String> _tabs;

  bool get _hasVenue => widget.event.venueId.isNotEmpty;
  bool get _hasWinner =>
      widget.event.winnerId != null && widget.event.winnerId!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    // Build dynamic tabs
    _tabs = ['Overview', 'Participants', 'Matches', 'Bracket'];
    if (_hasVenue) _tabs.add('Venue');
    if (_hasWinner) _tabs.add('Winner');

    _tabController = TabController(length: _tabs.length, vsync: this);

    _participantController = Get.put(EventParticipantController());
    _participantController.checkRegistration(
      widget.event.id,
      UserController.instance.user.value.id,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = UserController.instance.user.value.role;
    final isAdminOrPartner =
        role == AppRole.admin || role == AppRole.partner;

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      bottomNavigationBar: isAdminOrPartner
          ? EventActionButton(event: widget.event)
          : widget.event.eventStatus == EventStatus.upcoming
          ? EventRegisterButton(event: widget.event)
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  TImageSlider(
                    images: [widget.event.imageUrl],
                    isNetworkImage: true,
                  ),

                  // Status + name
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        TSizes.defaultSpace, TSizes.defaultSpace,
                        TSizes.defaultSpace, TSizes.spaceBtwItems),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EventStatusBadge(status: widget.event.eventStatus),
                        const SizedBox(height: 8),
                        Text(
                          widget.event.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                CueXTabBar(
                  controller: _tabController,
                  tabs: _tabs,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(event: widget.event),
            EventParticipantsScreen(eventId: widget.event.id, showHeader: false),
            SingleChildScrollView(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: EventMatchesWidget(eventId: widget.event.id),
            ),
            EventDrawScreen(eventId: widget.event.id), // add here
            if (_hasVenue)
              SingleChildScrollView(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: EventVenueWidget(venueId: widget.event.venueId),
              ),
            if (_hasWinner)
              SingleChildScrollView(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: EventWinnerWidget(winnerId: widget.event.winnerId!),
              ),
          ],
        ),
      ),
    );
  }
}

/// Overview tab content
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Info grid
          EventInfoGrid(event: event),
          const SizedBox(height: TSizes.spaceBtwSections / 2),

          // Prize banner
          EventPrizeBanner(event: event),
          if ((event.entryFee != null && event.entryFee! > 0) ||
              (event.prizePool != null && event.prizePool! > 0))
            const SizedBox(height: TSizes.spaceBtwSections / 2),

          // Participants count card
          ParticipantNumberCard(
            eventId: event.id,
            maxParticipants: event.maxParticipants,
          ),
          const SizedBox(height: TSizes.spaceBtwSections / 2),

          // Description
          if (event.description != null && event.description!.isNotEmpty) ...[
            const TSectionHeading(
                title: 'About', showActionButton: false),
            const SizedBox(height: TSizes.spaceBtwItems),
            ReadMoreText(
              parseDescription(event.description),
              trimLines: 4,
              colorClickableText: Colors.red,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' Show more',
              trimExpandedText: ' Less',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.6),
              moreStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.red),
              lessStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.red),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ],
      ),
    );
  }
}

/// Sticky tab bar delegate for SliverPersistentHeader
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);
  final Widget tabBar;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF121212),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

String parseDescription(String? jsonDescription) {
  if (jsonDescription == null) return '';
  try {
    final List<dynamic> delta = jsonDecode(jsonDescription);
    String description = '';
    for (var block in delta) {
      if (block is Map && block.containsKey('insert')) {
        description += block['insert'].toString().replaceAll('\\n', '\n');
      }
    }
    return description.trim();
  } catch (e) {
    return jsonDescription ?? '';
  }
}