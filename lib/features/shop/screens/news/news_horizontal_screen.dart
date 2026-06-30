import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../controllers/news_controller.dart';
import '../../models/news_model.dart';
import 'news_details_screen.dart';
import 'news_list_screen.dart';

class NewsVerticalList extends StatelessWidget {
  const NewsVerticalList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NewsController>()
        ? Get.find<NewsController>()
        : Get.put(NewsController());

    return Obx(() {
      // ── Shimmer ──────────────────────────
      if (controller.isLoading.value &&
          controller.publishedNews.isEmpty) {
        return const _NewsShimmer();
      }

      final news = controller.publishedNews
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final top5 = news.take(5).toList();
      if (top5.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          // ── News items ────────────────────
          ...top5.asMap().entries.map((entry) => _NewsRow(
            news: entry.value,
            isLast: entry.key == top5.length - 1,
          )),

          // ── View all button ───────────────
          if (news.length > 5) ...[
            const SizedBox(height: TSizes.spaceBtwItems),
            GestureDetector(
              onTap: () => Get.to(() => const NewsListScreen()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View All Updates',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Iconsax.arrow_right_3,
                      size: 14,
                      color: TColors.june,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────
// News Row
// ─────────────────────────────────────────────

class _NewsRow extends StatelessWidget {
  const _NewsRow({required this.news, required this.isLast});

  final NewsModel news;
  final bool isLast;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isValidUrl =
        news.imageUrl.isNotEmpty && news.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () => Get.to(() => NewsDetailScreen(news: news)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        child: Row(
          children: [
            // ── Image ────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isValidUrl
                  ? CachedNetworkImage(
                imageUrl: news.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (_, __) => const TShimmerEffect(
                  width: 64,
                  height: 64,
                  radius: 0,
                ),
                errorWidget: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),

            // ── Info ─────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // // Category
                  // if (news.category.isNotEmpty)
                  //   Text(
                  //     news.category.toUpperCase(),
                  //     style: TextStyle(
                  //       fontSize: 9,
                  //       fontWeight: FontWeight.w700,
                  //       color: TColors.june,
                  //       letterSpacing: 0.5,
                  //     ),
                  //   ),
                  const SizedBox(height: 3),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Date
                  Text(
                    _timeAgo(news.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Chevron ──────────────────
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(
      Iconsax.document_text,
      size: 24,
      color: Colors.white.withOpacity(0.15),
    ),
  );
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _NewsShimmer extends StatelessWidget {
  const _NewsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
            (i) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: i < 3
                ? Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            )
                : null,
          ),
          child: Row(
            children: [
              TShimmerEffect(width: 64, height: 64, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TShimmerEffect(width: 60, height: 9, radius: 4),
                    const SizedBox(height: 5),
                    TShimmerEffect(
                        width: double.infinity, height: 13, radius: 4),
                    const SizedBox(height: 4),
                    TShimmerEffect(width: 120, height: 13, radius: 4),
                    const SizedBox(height: 5),
                    TShimmerEffect(width: 60, height: 9, radius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}