import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/venue_model.dart';
import '../venue_details_screen.dart';

// ─────────────────────────────────────────────
// Venue Card
// ─────────────────────────────────────────────

class VenueCard extends StatelessWidget {
  const VenueCard({super.key, required this.venue, this.onTap});

  final VenueModel venue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.to(() => VenueDetailScreen(venue: venue)),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF141414),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ───────────────────────
            _VenueImage(imageUrl: venue.thumbnailImage),

            // ── Details ─────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Iconsax.location, size: 11, color: Colors.white38),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Status badge
                  _StatusBadge(status: venue.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Venue Image with shimmer + error
// ─────────────────────────────────────────────

class _VenueImage extends StatelessWidget {
  const _VenueImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final isValid = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    if (!isValid) return _ErrorImage();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 130,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => const TShimmerEffect(
        width: double.infinity,
        height: 130,
        radius: 0,
      ),
      errorWidget: (_, __, ___) => _ErrorImage(),
    );
  }
}

class _ErrorImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      color: const Color(0xFF1E1E1E),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.building_3, size: 32, color: Colors.white12),
          const SizedBox(height: 6),
          const Text(
            'No Image',
            style: TextStyle(fontSize: 10, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isOpen = status.toLowerCase() == 'open';
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOpen ? const Color(0xFF2ECC71) : Colors.white24,
          ),
        ),
        const SizedBox(width: 5),
        // Text(
        //   isOpen ? 'Open' : 'Closed',
        //   style: TextStyle(
        //     fontSize: 10,
        //     fontWeight: FontWeight.w600,
        //     color: isOpen ? const Color(0xFF2ECC71) : Colors.white24,
        //     letterSpacing: 0.3,
        //   ),
        // ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Venue Card Shimmer — use while loading list
// ─────────────────────────────────────────────

class VenueCardShimmer extends StatelessWidget {
  const VenueCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF141414),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          const TShimmerEffect(width: double.infinity, height: 130, radius: 0),
          // Details shimmer
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TShimmerEffect(width: 130, height: 13, radius: 4),
                const SizedBox(height: 6),
                TShimmerEffect(width: 90, height: 10, radius: 4),
                const SizedBox(height: 10),
                TShimmerEffect(width: 50, height: 10, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}