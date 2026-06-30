import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/venue_model.dart';

class VenueListTile extends StatelessWidget {
  const VenueListTile({super.key, required this.venue, this.onTap});

  final VenueModel venue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: venue.isActive ? null : Colors.grey.withOpacity(0.05),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Opacity(
          opacity: venue.isActive ? 1.0 : 0.6,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                child: venue.thumbnailImage.isNotEmpty
                    ? Image.network(venue.thumbnailImage, width: 48, height: 48, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initials(context))
                    : _initials(context),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(venue.name, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 6),
                        _badge(venue.isActive ? 'Active' : 'Inactive', venue.isActive ? Colors.green : Colors.red),
                        if (venue.isFeatured) ...[const SizedBox(width: 4), _badge('Featured', Colors.orange)],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Iconsax.location, size: 11, color: Colors.grey),
                        const SizedBox(width: 3),
                        Expanded(child: Text('${venue.city}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        if (venue.tablesCount > 0) ...[
                          const Icon(Iconsax.grid_1, size: 11, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text('${venue.tablesCount} tables', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                        ],
                        if (venue.streamingEnabled) ...[
                          const SizedBox(width: 6),
                          _badge('Live', TColors.primary),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initials(BuildContext context) {
    final initials = venue.name.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    return Container(
      width: 48,
      height: 48,
      color: TColors.primary.withOpacity(0.1),
      child: Center(child: Text(initials, style: TextStyle(color: TColors.primary, fontWeight: FontWeight.w500, fontSize: 14))),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}