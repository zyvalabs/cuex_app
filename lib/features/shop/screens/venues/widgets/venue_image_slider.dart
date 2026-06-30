import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../models/venue_model.dart';

class TVenueImageSlider extends StatefulWidget {
  const TVenueImageSlider({super.key, required this.venue});
  final VenueModel venue;

  @override
  State<TVenueImageSlider> createState() => _TVenueImageSliderState();
}

class _TVenueImageSliderState extends State<TVenueImageSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = [
      if (widget.venue.thumbnailImage.isNotEmpty) widget.venue.thumbnailImage,
      ...widget.venue.images.where((i) => i.isNotEmpty),
    ];

    if (images.isEmpty) {
      return SizedBox(
        height: 400,
        child: Container(
          color: Colors.grey.withOpacity(0.1),
          child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      height: 400,
      child: Stack(
        children: [

          // Full width/height PageView
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 400,
              placeholder: (_, __) => const TShimmerEffect(width: double.infinity, height: 400),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.withOpacity(0.1),
                child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
              ),
            ),
          ),

          // Dark gradient overlay at top and bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Appbar with share
          TAppBar(
            showBackArrow: true,
            showSkipButton: false,
            showActions: true,
            actionIcon: Icons.share_outlined,
            actionOnPressed: () => Share.share(
              '${widget.venue.name} — ${widget.venue.address}\n\nCheck it out on CueX!',
            ),
          ),

          // Dot indicator at bottom
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == i ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(99),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}