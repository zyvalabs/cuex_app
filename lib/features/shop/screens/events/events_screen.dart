import 'package:cuex_app/features/shop/screens/events/widgets/add_event_fab.dart';
import 'package:cuex_app/features/shop/screens/events/widgets/event_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/tab bar/cuex_tab_bar.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/venue_controller.dart';
import 'widgets/event_list_tab.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.showBackArrow = true});
  final bool showBackArrow;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late final EventController eventController;
  late TabController _tabController;
  late final AppRole role;
  late final String venueId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  bool get isAdmin => role == AppRole.admin;
  bool get isPartner => role == AppRole.partner;
  bool get isPlayer => role == AppRole.player;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    eventController = Get.isRegistered<EventController>()
        ? Get.find<EventController>()
        : Get.put(EventController());
    role = UserController.instance.user.value.role;
    venueId = VenueController.instance.venue.value.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (isAdmin) {
      await eventController.fetchEvents();
    } else if (isPartner) {
      await eventController.fetchEventsByVenue(venueId);
    } else {
      await eventController.fetchEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: widget.showBackArrow,
        showActions: false,
        showSkipButton: false,
        title: Text(
          isAdmin ? 'All Events' : 'Events',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),

      // ── Modern FAB ────────────────────────
      floatingActionButton: (isAdmin || isPartner)
          ? AddEventFab(
        onTap: () async {
          await Get.toNamed(TRoutes.addEvents, arguments: venueId);
          _refresh();
        },
      )
          : null,

      body: Column(
        children: [
          // ── Search bar ────────────────────
          EventSearchBar(
            controller: _searchController,
            query: _searchQuery,
            onChanged: (val) => setState(() => _searchQuery = val),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),

          // ── Tab bar ───────────────────────
          CueXTabBar(
            controller: _tabController,
            tabs: const ['Live', 'Upcoming', 'Completed'],
            liveTabIndex: 0,
          ),

          // ── Tab content ───────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EventListTab(
                  status: EventStatus.live,
                  searchQuery: _searchQuery,
                  showActions: isAdmin,
                  onRefresh: _refresh,
                ),
                EventListTab(
                  status: EventStatus.upcoming,
                  searchQuery: _searchQuery,
                  showActions: isAdmin,
                  onRefresh: _refresh,
                ),
                EventListTab(
                  status: EventStatus.completed,
                  searchQuery: _searchQuery,
                  showActions: isAdmin,
                  onRefresh: _refresh,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

