// ─────────────────────────────────────────────
// news_list_screen.dart
// ─────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cuex_app/features/shop/screens/news/widget/category_chips.dart';
import 'package:cuex_app/features/shop/screens/news/widget/news_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/news_controller.dart';
import '../../models/news_model.dart';
import 'add_edit_screen.dart';
import 'news_details_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late final NewsController controller;
  final selectedCategory = 'All'.obs;
  final isAdmin = UserController.instance.user.value.role == AppRole.admin;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<NewsController>()
        ? Get.find<NewsController>()
        : Get.put(NewsController());
    if (isAdmin) controller.fetchAllNews();
  }

  Future<void> _refresh() async {
    if (isAdmin) {
      await controller.fetchAllNews();
    } else {
      await controller.fetchPublishedNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text(
          'News & Updates',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),

      // ── FAB ──────────────────────────────
      floatingActionButton: isAdmin
          ? _AddNewsFab(onTap: () async {
        await Get.to(() => const AddEditNewsScreen());
        controller.fetchAllNews();
      })
          : null,

      body: Column(
        children: [
          // ── Category chips ────────────────
          const SizedBox(height: 10),
          NewsCategoryChips(
            selected: selectedCategory,
            onSelected: (val) => selectedCategory.value = val,
          ),
          const SizedBox(height: 10),

          // ── List ──────────────────────────
          Expanded(
            child: Obx(() {
              // Shimmer
              if (controller.isLoading.value) {
                return const _NewsListShimmer();
              }

              final source =
              isAdmin ? controller.allNews : controller.publishedNews;
              final filtered = selectedCategory.value == 'All'
                  ? source
                  : source
                  .where((n) => n.category == selectedCategory.value)
                  .toList();

              // Empty
              if (filtered.isEmpty) {
                return const _EmptyState();
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                color: TColors.june,
                backgroundColor: const Color(0xFF1C1C1C),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    TSizes.defaultSpace,
                    4,
                    TSizes.defaultSpace,
                    100,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: TSizes.spaceBtwItems),
                  itemBuilder: (_, i) {
                    final news = filtered[i];
                    return NewsCard(
                      news: news,
                      showActions: isAdmin,
                      onTap: () => Get.to(() => NewsDetailScreen(news: news)),
                      onEdit: () async {
                        await Get.to(() => AddEditNewsScreen(news: news));
                        controller.fetchAllNews();
                      },
                      onDelete: () => _confirmDelete(context, news.id),
                      onTogglePublish: (val) =>
                          controller.togglePublish(news.id, val),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String newsId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, size: 24, color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete News',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This cannot be undone.',
              style: TextStyle(fontSize: 13, color: Colors.white38),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      minimumSize: const Size(double.infinity, 46),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.deleteNews(newsId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────
// Add News FAB
// ─────────────────────────────────────────────

class _AddNewsFab extends StatelessWidget {
  const _AddNewsFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: TColors.june,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: TColors.june.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 20, color: Colors.black),
            SizedBox(width: 6),
            Text(
              'Add News',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _NewsListShimmer extends StatelessWidget {
  const _NewsListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        TSizes.defaultSpace,
        4,
        TSizes.defaultSpace,
        100,
      ),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            TShimmerEffect(width: 72, height: 72, radius: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TShimmerEffect(width: 60, height: 16, radius: 99),
                  const SizedBox(height: 8),
                  TShimmerEffect(width: double.infinity, height: 13, radius: 4),
                  const SizedBox(height: 5),
                  TShimmerEffect(width: 140, height: 13, radius: 4),
                  const SizedBox(height: 8),
                  TShimmerEffect(width: 80, height: 10, radius: 4),
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
// Empty State
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Iconsax.document_text, size: 30, color: Colors.white24),
          ),
          const SizedBox(height: 16),
          const Text(
            'No News Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nothing in this category yet.',
            style: TextStyle(fontSize: 12, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}