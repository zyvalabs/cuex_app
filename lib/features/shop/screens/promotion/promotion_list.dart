import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

import '../../controllers/promotion_controller.dart';
import '../../models/promotion_model.dart';
import 'add_edit_promo.dart';
import 'widgets/promo_card.dart';

class PromoManagementScreen extends StatefulWidget {
  const PromoManagementScreen({super.key});

  @override
  State<PromoManagementScreen> createState() => _PromoManagementScreenState();
}

class _PromoManagementScreenState extends State<PromoManagementScreen> {
  late final PromotionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PromotionController>()
        ? Get.find<PromotionController>()
        : Get.put(PromotionController());
    controller.fetchAllPromos();
  }

  void _confirmDelete(PromotionModel promo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Promotion',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${promo.title}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deletePromo(promo);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: TAppBar(
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
        title: Text(
          'Promotions',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => const AddEditPromoScreen());
          controller.fetchAllPromos();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Promo'),
        backgroundColor: Colors.red,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allPromos.isEmpty) {
          return _PromoShimmer();
        }

        if (controller.allPromos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.image, size: 48, color: Colors.grey.shade700),
                const SizedBox(height: 12),
                Text(
                  'No promotions yet',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add your first promotion',
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAllPromos,
          color: TColors.primary,
          backgroundColor: const Color(0xFF1C1C1C),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              TSizes.defaultSpace,
              TSizes.defaultSpace,
              TSizes.defaultSpace,
              100, // extra space for FAB
            ),
            itemCount: controller.allPromos.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: TSizes.spaceBtwItems),
            itemBuilder: (_, i) {
              final promo = controller.allPromos[i];
              return PromoCard(
                promo: promo,
                onEdit: () async {
                  await Get.to(() => AddEditPromoScreen(promo: promo));
                  controller.fetchAllPromos();
                },
                onDelete: () => _confirmDelete(promo),
                onToggleActive: () => controller.toggleActive(promo),
              );
            },
          ),
        );
      }),
    );
  }
}

class _PromoShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: 3,
      separatorBuilder: (_, __) =>
      const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF1C1C1C),
        highlightColor: const Color(0xFF2A2A2A),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          ),
          child: Column(
            children: [
              // Image placeholder
              Container(
                height: 160,
                width: double.infinity,
                color: const Color(0xFF2A2A2A),
              ),
              // Info placeholder
              Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 200,
                      color: const Color(0xFF2A2A2A),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 140,
                      color: const Color(0xFF2A2A2A),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            color: const Color(0xFF2A2A2A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 36,
                          width: 80,
                          color: const Color(0xFF2A2A2A),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 36,
                          width: 80,
                          color: const Color(0xFF2A2A2A),
                        ),
                      ],
                    ),
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