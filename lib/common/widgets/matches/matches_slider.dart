import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/match_model.dart';
import '../../../features/shop/screens/matches/match_detail.dart';
import '../shimmers/shimmer.dart';
import 'card/match_card.dart';

class MatchesSlider extends StatelessWidget {
  const MatchesSlider({
    super.key,
    required this.matches,
    this.height = 280,
  });

  final RxList<MatchModel> matches;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show shimmer while loading
      if (matches.isEmpty) {
        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, __) => const TMatchCardShimmer(),
          ),
        );
      }

      // Show horizontal scrollable cards
      return SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: matches.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: MatchCard(
                match: matches[index],
                onTap: () => Get.to(() => MatchDetailScreen(match: matches[index])),
              ),
            );
          },
        ),
      );
    });
  }
}

// Create shimmer for match cards
class TMatchCardShimmer extends StatelessWidget {
  const TMatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 280,
      child: const TShimmerEffect(
        width: double.infinity,
        height: 280,
        radius: 12,
      ),
    );
  }
}