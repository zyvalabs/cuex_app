import 'package:cuex_app/features/shop/screens/venues/widgets/venue_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/lcoation/location_widget.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/venue_controller.dart';

class VenueScreen extends StatelessWidget {
  const VenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VenueController());

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        title: const LocationWidget(),
        showActions: false,
        showSkipButton: false,
      ),
      body: Obx(() {
        // ── Shimmer while loading ──
        if (controller.isLoading.value && controller.allVenues.isEmpty) {
          return const _VenueShimmerList();
        }

        // ── Empty state ──
        if (controller.allVenues.isEmpty) {
          return const _EmptyState();
        }

        // ── Venue list ──
        return RefreshIndicator(
          onRefresh: controller.fetchAllVenues,
          color: const Color(0xFF2ECC71),
          backgroundColor: const Color(0xFF1C1C1C),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  TSizes.defaultSpace,
                  TSizes.defaultSpace,
                  TSizes.defaultSpace,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Venues Near You',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '${controller.allVenues.length} found',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                    ],
                  ),
                ),
              ),

              // ── Cards ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, index) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: TSizes.spaceBtwItems,
                      ),
                      child: VenueCard(
                        venue: controller.allVenues[index],
                      ),
                    ),
                    childCount: controller.allVenues.length,
                  ),
                ),
              ),

              const SliverPadding(
                padding: EdgeInsets.only(bottom: 100),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer List
// ─────────────────────────────────────────────

class _VenueShimmerList extends StatelessWidget {
  const _VenueShimmerList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          ...List.generate(
            4,
                (_) => const Padding(
              padding: EdgeInsets.only(bottom: TSizes.spaceBtwItems),
              child: VenueCardShimmer(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final controller = VenueController.instance;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.building_3,
              size: 30,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Venues Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No venues in your area yet.\nPull down to refresh.',
            style: TextStyle(fontSize: 12, color: Colors.white38),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: controller.fetchAllVenues,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.refresh, size: 14, color: const Color(0xFF2ECC71)),
                  const SizedBox(width: 6),
                  const Text(
                    'Refresh',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}