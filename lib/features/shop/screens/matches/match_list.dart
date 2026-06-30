import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/empty/empty_state.dart';
import '../../../../common/widgets/matches/card/match_card.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/matches_controller.dart';
import '../live_scroring/live_scoring.dart';

class MatchList extends StatelessWidget {

  final String status;
  final bool filterToday;

  const MatchList({
    super.key,
    required this.status,
    this.filterToday = false,
  });

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<MatchController>();

    return Obx(() {

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final today = DateTime.now();

      final filtered = controller.venueMatches.where((m) {

        if (m.matchStatus != status) return false;

        if (filterToday) {

          if (m.updatedAt == null) return false;

          final d = m.updatedAt!;

          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        }

        return true;

      }).toList();

      if (filtered.isEmpty) {

        if (status == 'live') {
          return TEmptyState(
            icon: Iconsax.activity,
            title: 'No Live Matches',
            subtitle: 'No matches are live right now',
            iconColor: Colors.red.withOpacity(0.5),
          );
        }

        if (status == 'upcoming') {
          return TEmptyState(
            icon: Iconsax.calendar,
            title: 'No Upcoming Matches',
            subtitle: 'Check back later for scheduled matches',
            iconColor: Colors.orange.withOpacity(0.5),
          );
        }

        return TEmptyState(
          icon: Iconsax.cup,
          title: 'No Completed Matches Today',
          subtitle: 'No matches were completed today',
          iconColor: Colors.grey.withOpacity(0.5),
          actionLabel: 'View All',
          onAction: () =>
              Get.toNamed(TRoutes.completedMatches),
        );
      }

      return ListView.separated(

        padding: const EdgeInsets.all(TSizes.defaultSpace),

        itemCount: filtered.length,

        separatorBuilder: (_, __) =>
        const SizedBox(height: TSizes.spaceBtwItems),

        itemBuilder: (_, index) {

          final match = filtered[index];

          return MatchCard(
            match: match,
            onTap: () => Get.to(
                  () => LiveScoringScreen(match: match),
            ),
          );
        },
      );
    });
  }
}