
// ─────────────────────────────────────────────
// News Card
// ─────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../models/news_model.dart';
import '../news_details_screen.dart';

class NewsHorizontalCard extends StatelessWidget {
  const NewsHorizontalCard({super.key, required this.news});
  final NewsModel news;

  @override
  Widget build(BuildContext context) {
    final isValidUrl = news.imageUrl.isNotEmpty && news.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () => Get.to(() => NewsDetailScreen(news: news)),
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // ── Image ──
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: isValidUrl
                  ? CachedNetworkImage(
                imageUrl: news.imageUrl,
                width: 85,
                height: 130,
                fit: BoxFit.cover,
                placeholder: (_, __) => const TShimmerEffect(width: 85, height: 130, radius: 0),
                errorWidget: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),
            ),

            // ── Content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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

                    // Title
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Date
                    Row(
                      children: [
                        const Icon(Iconsax.clock, size: 10, color: Colors.white24),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM').format(news.createdAt),
                          style: const TextStyle(fontSize: 10, color: Colors.white24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 85,
    height: 130,
    color: const Color(0xFF1E1E1E),
    child: const Icon(Iconsax.image, size: 22, color: Colors.white12),
  );
}