import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/match_stat_controller.dart';
import '../../matches/widgets/frame_stats_widget.dart';

class FrameHistoryList extends StatelessWidget {
  const FrameHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final matchStatsController = Get.find<MatchStatsController>();

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isTablet ? 24 : 16, 20, isTablet ? 24 : 16, 8),
            child: Row(
              children: [
                const Icon(Icons.layers_outlined, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Frame History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
            child: const Divider(color: Colors.white12),
          ),
        ),
        SliverToBoxAdapter(
          child: Obx(() {
            final frames = matchStatsController.frames;
            if (frames.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.layers_outlined, color: Colors.white12, size: 40),
                      SizedBox(height: 10),
                      Text('No frames yet', style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: frames.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 8),
                child: FrameStatsWidget(frame: frames[index]),
              ),
            );
          }),
        ),
      ],
    );
  }
}