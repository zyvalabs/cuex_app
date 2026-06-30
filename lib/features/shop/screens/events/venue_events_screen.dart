// import 'package:cuex_app/features/shop/screens/events/widgets/compact_event_card.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../common/widgets/appbar/appbar.dart';
// import '../../../../common/widgets/appbar/tabbar.dart';
// import '../../../../routes/routes.dart';
// import '../../../../utils/constants/colors.dart';
// import '../../../../utils/constants/enums.dart';
// import '../../../../utils/helpers/helper_functions.dart';
// import '../../controllers/event_controller.dart';
// import '../../controllers/venue_controller.dart';
// import '../../../personalization/controllers/user_controller.dart';
//
// class VenueEventsScreen extends StatefulWidget {
//   const VenueEventsScreen({super.key});
//
//   @override
//   State<VenueEventsScreen> createState() => _VenueEventsScreenState();
// }
//
// class _VenueEventsScreenState extends State<VenueEventsScreen> {
//   late final EventController eventController;
//   late final bool isAdmin;
//   late final String venueId;
//
//   @override
//   void initState() {
//     super.initState();
//     eventController = Get.put(EventController());
//     isAdmin = UserController.instance.user.value.role == AppRole.admin;
//     venueId = VenueController.instance.venue.value.id;
//     _refresh();
//   }
//
//   Future<void> _refresh() async {
//     if (isAdmin) {
//       await eventController.fetchEvents();
//     } else {
//       await eventController.fetchEventsByVenue(venueId);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dark = THelperFunctions.isDarkMode(context);
//
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         backgroundColor: TColors.peppercorn,
//         appBar: TAppBar(
//           showBackArrow: true,
//           title: Text(
//             isAdmin ? 'All Events' : 'Venue Events',
//             style: Theme.of(context).textTheme.headlineMedium,
//           ),
//           showActions: false,
//           showSkipButton: false,
//           actions: [
//             // Loading indicator
//             Obx(() => eventController.isLoading.value
//                 ? const Padding(
//               padding: EdgeInsets.only(right: 16),
//               child: SizedBox(
//                 width: 18,
//                 height: 18,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white54,
//                 ),
//               ),
//             )
//                 : IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.white54),
//               onPressed: _refresh,
//             )),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () async {
//             await Get.toNamed(TRoutes.addEvents, arguments: venueId);
//             _refresh();
//           },
//           icon: const Icon(Icons.add),
//           label: const Text('Add Event'),
//           backgroundColor: Colors.red,
//         ),
//         body: NestedScrollView(
//           headerSliverBuilder: (_, innerBoxIsScrolled) {
//             return [
//               SliverAppBar(
//                 pinned: true,
//                 floating: true,
//                 expandedHeight: 40,
//                 automaticallyImplyLeading: false,
//                 backgroundColor: dark ? Colors.black : TColors.white,
//                 bottom: const TTabBar(
//                   tabs: [
//                     Tab(child: Text('Live')),
//                     Tab(child: Text('Upcoming')),
//                     Tab(child: Text('Completed')),
//                   ],
//                 ),
//               ),
//             ];
//           },
//           body: Obx(() {
//             final events = eventController.allEvents;
//
//             Widget buildList(EventStatus status) {
//               final filtered =
//               events.where((e) => e.eventStatus == status).toList();
//
//               return RefreshIndicator(
//                 onRefresh: _refresh,
//                 color: Colors.red,
//                 backgroundColor: const Color(0xFF1A1A1A),
//                 child: filtered.isEmpty
//                     ? ListView(
//                   children: [
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.4,
//                       child: Center(
//                         child: Text(
//                           'No ${status.value} events',
//                           style:
//                           const TextStyle(color: Colors.white38),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//                     : ListView.builder(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   itemCount: filtered.length,
//                   itemBuilder: (_, i) =>
//                       CompactEventCard(event: filtered[i]),
//                 ),
//               );
//             }
//
//             return TabBarView(
//               children: [
//                 buildList(EventStatus.live),
//                 buildList(EventStatus.upcoming),
//                 buildList(EventStatus.completed),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }