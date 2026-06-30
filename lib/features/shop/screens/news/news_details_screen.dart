import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../models/news_model.dart';


class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.news});
  final NewsModel news;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: news.imageUrl.isNotEmpty ? 480 : 0,
            pinned: true,
            flexibleSpace: news.imageUrl.isNotEmpty
                ? FlexibleSpaceBar(
              background: Image.network(
                news.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            )
                : null,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.arrow_left, color: Colors.white),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Category + date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          news.category,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Iconsax.calendar, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(news.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Title
                  Text(
                    news.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Description
                  Text(
                    news.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade300,
                      height: 1.7,
                    ),
                  ),

                  // Video link
                  if (news.videoUrl != null && news.videoUrl!.isNotEmpty) ...[
                    const SizedBox(height: TSizes.spaceBtwSections),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(news.videoUrl!);
                        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(TSizes.md),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.video_play, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Watch Video', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: TSizes.defaultSpace),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}