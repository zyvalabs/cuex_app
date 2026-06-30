import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/promotion_model.dart';

class PromoCard extends StatelessWidget {
  const PromoCard({
    super.key,
    required this.promo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final PromotionModel promo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(
          color: promo.isActive
              ? Colors.red.withOpacity(0.2)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Image / Video placeholder
          Stack(
            children: [
              // Thumbnail
              promo.imageUrl.isNotEmpty
                  ? Image.network(
                promo.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),

              // Type badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        promo.type == 'video'
                            ? Iconsax.video
                            : Iconsax.image,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        promo.type == 'video' ? 'Video' : 'Image',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              // Active badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: promo.isActive
                        ? Colors.green.withOpacity(0.85)
                        : Colors.grey.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    promo.isActive ? 'Active' : 'Hidden',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // View count
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.eye, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${promo.viewCount} views',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

              // Order badge
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${promo.order + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),

          // Info + actions
          Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Title + button title
                Text(
                  promo.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Iconsax.mouse, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      promo.buttonTitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      promo.linkType == 'internal'
                          ? Iconsax.mobile
                          : Iconsax.global,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        promo.linkRoute,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Added ${DateFormat('dd MMM yyyy').format(promo.createdAt)}',
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 10),
                ),
                const SizedBox(height: TSizes.sm),

                // Actions row
                Row(
                  children: [

                    // Toggle active
                    Expanded(
                      child: GestureDetector(
                        onTap: onToggleActive,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                          decoration: BoxDecoration(
                            color: promo.isActive
                                ? Colors.red.withOpacity(0.1)
                                : Colors.white.withOpacity(0.05),
                            borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusMd),
                            border: Border.all(
                              color: promo.isActive
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                promo.isActive
                                    ? Iconsax.eye_slash
                                    : Iconsax.eye,
                                size: 14,
                                color: promo.isActive
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                promo.isActive ? 'Hide' : 'Show',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: promo.isActive
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Edit
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius:
                          BorderRadius.circular(TSizes.cardRadiusMd),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.edit,
                                size: 14, color: Colors.white70),
                            SizedBox(width: 6),
                            Text('Edit',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius:
                          BorderRadius.circular(TSizes.cardRadiusMd),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.trash,
                                size: 14, color: Colors.red),
                            SizedBox(width: 6),
                            Text('Delete',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
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

  Widget _placeholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(Iconsax.image, size: 40, color: Colors.grey),
      ),
    );
  }
}