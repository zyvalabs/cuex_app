import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/shop/models/match_model.dart';
import '../../../features/shop/screens/matches/match_detail.dart';
import 'card/match_card.dart';

class THorizontalMatchList extends StatelessWidget {
  const THorizontalMatchList({
    super.key,
    required this.matches,
    this.height = 220,
  });

  final RxList<MatchModel> matches;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (matches.isEmpty) {
        return SizedBox(
          height: height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.video_slash, size: 64, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                Text(
                  'No Live Matches',
                  style: Theme.of(context).textTheme.titleLarge?.apply(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later',
                  style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: matches.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, index) => SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: MatchCard(
              match: matches[index],
              onTap: () => Get.to(() => MatchDetailScreen(match: matches[index])),
            ),
          ),
        ),
      );
    });
  }
}