import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/news_model.dart';

// ─────────────────────────────────────────────
// News Card
// ─────────────────────────────────────────────

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.news,
    this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.onTogglePublish,
  });

  final NewsModel news;
  final VoidCallback? onTap;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(bool)? onTogglePublish;

  @override
  Widget build(BuildContext context) {
    final isValidUrl =
        news.imageUrl.isNotEmpty && news.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // ── Main row ──
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: isValidUrl
                      ? CachedNetworkImage(
                    imageUrl: news.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const TShimmerEffect(
                      width: 72,
                      height: 72,
                      radius: 0,
                    ),
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                      : _placeholder(),
                ),
                const SizedBox(width: 10),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + draft badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: TColors.june.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              news.category,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: TColors.june,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!news.isPublished && showActions)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text(
                                'Draft',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Title
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // Date
                      Row(
                        children: [
                          const Icon(Iconsax.clock, size: 10, color: Colors.white24),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(news.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Admin actions ──
          if (showActions) ...[
            Container(
              height: 0.5,
              color: Colors.white.withOpacity(0.06),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Switch(
                    value: news.isPublished,
                    onChanged: onTogglePublish,
                    activeColor: TColors.june,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    news.isPublished ? 'Published' : 'Draft',
                    style: TextStyle(
                      fontSize: 11,
                      color: news.isPublished ? TColors.june : Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.edit, size: 14, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.trash, size: 14, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Iconsax.image, size: 22, color: Colors.white12),
  );
}