import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/dot indicator/dots_indicator.dart';
import '../../../../../common/widgets/matches/card/match_card.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/match_model.dart';
import '../../home/widgets/view_all.dart';
import '../../matches/match_detail.dart';
import '../../matches/matches_screen.dart';

class HorizontalMatchesSlider extends StatefulWidget {
  const HorizontalMatchesSlider({
    super.key,
    required this.matches,
    required this.emptyMessage,
    required this.emptyIcon,
    this.initialTab = 0,
  });

  final RxList<MatchModel> matches;
  final String emptyMessage;
  final IconData emptyIcon;
  final int initialTab;

  @override
  State<HorizontalMatchesSlider> createState() => _HorizontalMatchesSliderState();
}

class _HorizontalMatchesSliderState extends State<HorizontalMatchesSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) setState(() => _currentPage = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final displayMatches = widget.matches.take(3).toList();
      final hasMore = widget.matches.length > 3;
      final totalSlots = displayMatches.length + (hasMore ? 1 : 0);

      if (displayMatches.isEmpty) {
        return SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.emptyIcon, size: 40, color: Colors.grey.shade700),
                const SizedBox(height: 8),
                Text(
                  widget.emptyMessage,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          SizedBox(
            height: 230,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalSlots,
              itemBuilder: (_, i) {
                if (hasMore && i == totalSlots - 1) {
                  return ViewAllCard(initialTab: widget.initialTab,);
                }
                final match = displayMatches[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: MatchCard(
                    match: match,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MatchDetailScreen(match: match)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: TSizes.sm),
          DotsIndicator(
            count: totalSlots,
            current: _currentPage,
          ),
        ],
      );
    });
  }
}
