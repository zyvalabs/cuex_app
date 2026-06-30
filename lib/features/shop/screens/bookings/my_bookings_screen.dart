import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/appbar/tabbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/booking_controller.dart';
import 'booking_list.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  Widget build(BuildContext context) {
    final bookingController = Get.put(BookingController());
    final dark = THelperFunctions.isDarkMode(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: TColors.peppercorn,
        appBar: TAppBar(
          title: Text('My Bookings', style: Theme.of(context).textTheme.headlineMedium),
          showActions: false,
          showSkipButton: false,
          showBackArrow: true,
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: false,
                toolbarHeight: 0,
                collapsedHeight: 0,
                automaticallyImplyLeading: false,
                backgroundColor: dark ? Colors.black : TColors.white,
                bottom: const TTabBar(
                  tabs: [
                    Tab(child: Text('Upcoming')),
                    Tab(child: Text('Completed')),
                    Tab(child: Text('Cancelled')),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              BookingsList(status: 'confirmed', controller: bookingController),
              BookingsList(status: 'completed', controller: bookingController),
              BookingsList(status: 'cancelled', controller: bookingController),
            ],
          ),
        ),
      ),
    );
  }
}
