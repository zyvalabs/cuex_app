import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../controllers/promotion_controller.dart';
import '../../../models/promotion_model.dart';

import '../promotion_list.dart';

class PromoSlider extends StatefulWidget {
  const PromoSlider({super.key});

  @override
  State<PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<PromoSlider> {
  final PageController _pageController = PageController();
  double _currentPage = 0;
  late final PromotionController controller;

  bool get _isAdmin =>
      UserController.instance.user.value.role == AppRole.admin;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PromotionController>()
        ? Get.find<PromotionController>()
        : Get.put(PromotionController());

    _pageController.addListener(() {
      if (mounted) setState(() => _currentPage = _pageController.page ?? 0);
    });

    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || controller.activePromos.isEmpty) return;
      if (!_pageController.hasClients) return;
      final next =
          (_currentPage.round() + 1) % controller.activePromos.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;
    final height = isTablet ? 280.0 : 200.0;

    return Obx(() {
      // Loading shimmer
      if (controller.isLoading.value && controller.activePromos.isEmpty) {
        return _PromoShimmer(height: height);
      }

      // Empty state
      if (controller.activePromos.isEmpty) {
        return _EmptyPromo(
          height: height,
          isAdmin: _isAdmin,
        );
      }

      final promos = controller.activePromos;

      return Column(
        children: [
          // Carousel
          SizedBox(
            height: height,
            child: Stack(
              children: [
                // Page view
                PageView.builder(
                  controller: _pageController,
                  itemCount: promos.length,
                  itemBuilder: (_, i) => _PromoCard(
                    promo: promos[i],
                    height: height,
                    onVisible: () =>
                        controller.incrementViewCount(promos[i].id),
                  ),
                ),

                // Dot indicators — top center
                if (promos.length > 1)
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(promos.length, (i) {
                        final isActive = i == _currentPage.round();
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                  ),

                // Admin manage button — bottom right
                if (_isAdmin)
                  Positioned(
                    bottom: 10,
                    right: TSizes.defaultSpace,
                    child: GestureDetector(
                      onTap: () async {
                        await Get.to(
                                () => const PromoManagementScreen());
                        controller.fetchActivePromos();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.edit_2,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Manage',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _PromoCard extends StatefulWidget {
  const _PromoCard({
    required this.promo,
    required this.height,
    required this.onVisible,
  });

  final PromotionModel promo;
  final double height;
  final VoidCallback onVisible;

  @override
  State<_PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<_PromoCard> {
  bool _viewCounted = false;

  @override
  void initState() {
    super.initState();
    if (!_viewCounted) {
      _viewCounted = true;
      widget.onVisible();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;

    return GestureDetector(
      onTap: () => PromotionController.instance.openLink(widget.promo),
      child: Stack(
        fit: StackFit.expand,
        children: [

          // Background image
          widget.promo.imageUrl.isNotEmpty
              ? Image.network(
            widget.promo.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Shimmer.fromColors(
                baseColor: const Color(0xFF1C1C1C),
                highlightColor: const Color(0xFF2A2A2A),
                child: Container(
                    color: const Color(0xFF1C1C1C)),
              );
            },
            errorBuilder: (_, __, ___) =>
                _VideoPlaceholder(promo: widget.promo),
          )
              : _VideoPlaceholder(promo: widget.promo),

          // Bottom gradient


          // Title + button
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Title
                Expanded(
                  child: Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 18 : 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      shadows: const [
                        Shadow(
                            color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),

                // CTA button
                if (widget.promo.buttonTitle.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.promo.buttonTitle,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward,
                            size: 12, color: Colors.black),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Video type placeholder
class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.promo});
  final PromotionModel promo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              promo.title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state — no promos
class _EmptyPromo extends StatelessWidget {
  const _EmptyPromo({required this.height, required this.isAdmin});
  final double height;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isTablet = sw > 600;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.defaultSpace),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Stack(
          children: [

            // Background decoration
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColors.primary.withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎱', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 10),
                  Text(
                    'Watch Every Shot.',
                    style: GoogleFonts.bebasNeue(
                      fontSize: isTablet ? 28 : 22,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Feel Every Moment.',
                    style: GoogleFonts.bebasNeue(
                      fontSize: isTablet ? 24 : 18,
                      color: Colors.red,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Live snooker & billiards — right here.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Get.to(
                              () => const PromoManagementScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.add,
                                size: 14, color: Colors.red),
                            SizedBox(width: 6),
                            Text(
                              'Add Promotion',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading
class _PromoShimmer extends StatelessWidget {
  const _PromoShimmer({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.defaultSpace),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1C1C1C),
        highlightColor: const Color(0xFF2A2A2A),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          ),
        ),
      ),
    );
  }
}