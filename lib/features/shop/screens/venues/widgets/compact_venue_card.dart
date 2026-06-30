import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/venue_model.dart';

class CompactVenueCard extends StatelessWidget {
  const CompactVenueCard({super.key, required this.venue, this.distanceKm});

  final VenueModel venue;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: Row(
        children: [
          /// Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
            child: Image.network(
              venue.thumbnailImage,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: TColors.darkGrey),
            ),
          ),
          const SizedBox(width: TSizes.spaceBtwItems),

          /// Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(venue.address, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Iconsax.location, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      distanceKm != null ? '${distanceKm!.toStringAsFixed(1)} km away' : venue.city,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}