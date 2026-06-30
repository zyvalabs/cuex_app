import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/empty/empty_state.dart';
import '../../../../common/widgets/matches/card/match_card.dart';
import '../../../../common/widgets/search/filter_search_bar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/completed_matches_controller.dart';
import '../live_scroring/live_scoring.dart';

class CompletedMatchesScreen extends GetView<CompletedMatchesController> {
  const CompletedMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: TColors.peppercorn,

      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Completed Matches',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showActions: false,
        showSkipButton: false,
      ),

      body: Column(
        children: [

          const SizedBox(height: TSizes.spaceBtwItems),

          /// SEARCH
          TFilterSearchBar(
            controller: controller.searchController,
            hintText: 'Search by player or event...',
            onChanged: controller.search,
          ),

          const SizedBox(height: TSizes.spaceBtwItems),

          /// MATCH LIST
          Expanded(
            child: GetBuilder<CompletedMatchesController>(
              id: 'matches',
              builder: (controller) {

                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = controller.filteredMatches();

                if (filtered.isEmpty) {
                  return const TEmptyState(
                    icon: Iconsax.cup,
                    title: 'No Completed Matches',
                    subtitle: 'No matches have been completed yet',
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
              },
            ),
          ),
        ],
      ),
    );
  }
}