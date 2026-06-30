import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../controllers/sport_controller.dart';
import '../../models/sport_model.dart';
import 'add_edit_sport.dart';

class SportsManagementScreen extends StatefulWidget {
  const SportsManagementScreen({super.key});

  @override
  State<SportsManagementScreen> createState() =>
      _SportsManagementScreenState();
}

class _SportsManagementScreenState extends State<SportsManagementScreen> {
  late final SportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SportController>()
        ? Get.find<SportController>()
        : Get.put(SportController());
    controller.fetchAllSports();
  }

  void _confirmDelete(SportModel sport) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Sport',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${sport.name}"? This cannot be undone.',
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
              controller.deleteSport(sport);
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
        title: Text('Sports Management',
            style: Theme.of(context).textTheme.headlineMedium),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => const AddEditSportScreen());
          controller.fetchAllSports();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Sport'),
        backgroundColor: Colors.red,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.allSports.isEmpty) {
          return _SportsShimmer();
        }

        if (controller.allSports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.cup, size: 48, color: Colors.grey.shade700),
                const SizedBox(height: 12),
                Text('No sports added yet',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Tap + to add your first sport',
                    style: TextStyle(
                        color: Colors.grey.shade700, fontSize: 12)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAllSports,
          color: TColors.primary,
          backgroundColor: const Color(0xFF1C1C1C),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              TSizes.defaultSpace,
              TSizes.defaultSpace,
              TSizes.defaultSpace,
              100,
            ),
            itemCount: controller.allSports.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final sport = controller.allSports[i];
              return _SportCard(
                sport: sport,
                onEdit: () async {
                  await Get.to(
                          () => AddEditSportScreen(sport: sport));
                  controller.fetchAllSports();
                },
                onDelete: () => _confirmDelete(sport),
                onToggleActive: () =>
                    controller.toggleActive(sport),
                onToggleFeatured: () =>
                    controller.toggleFeatured(sport),
                onToggleTesting: () =>
                    controller.toggleTesting(sport),
              );
            },
          ),
        );
      }),
    );
  }
}

class _SportCard extends StatelessWidget {
  const _SportCard({
    required this.sport,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleFeatured,
    required this.onToggleTesting,
  });

  final SportModel sport;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleFeatured;
  final VoidCallback onToggleTesting;

  @override
  Widget build(BuildContext context) {
    final isValidUrl = sport.iconUrl.isNotEmpty &&
        sport.iconUrl.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: sport.isActive
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
        ),
      ),
      child: Column(
        children: [

          // Main row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [

                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isValidUrl
                        ? Image.network(
                      sport.iconUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Iconsax.cup,
                          size: 22, color: Colors.grey),
                    )
                        : const Icon(Iconsax.cup,
                        size: 22, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (sport.description != null &&
                          sport.description!.isNotEmpty)
                        Text(
                          sport.description!,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),

                      // Badges
                      Row(
                        children: [
                          if (sport.isActive)
                            _Badge(
                                label: 'Active',
                                color: Colors.green),
                          if (!sport.isActive)
                            _Badge(
                                label: 'Hidden',
                                color: Colors.grey),
                          if (sport.isFeatured) ...[
                            const SizedBox(width: 4),
                            _Badge(
                                label: 'Featured',
                                color: const Color(0xFFD4A843)),
                          ],
                          if (sport.isTesting) ...[
                            const SizedBox(width: 4),
                            _Badge(
                                label: 'Testing',
                                color: Colors.orange),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Order
                Text(
                  '#${sport.order + 1}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 12),

                // Edit
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.edit,
                        size: 15, color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 8),

                // Delete
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.trash,
                        size: 15, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

          // Toggle row
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14)),
              border: Border(
                top: BorderSide(
                    color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                _ToggleChip(
                  label: 'Active',
                  value: sport.isActive,
                  onTap: onToggleActive,
                ),
                const SizedBox(width: 8),
                _ToggleChip(
                  label: 'Featured',
                  value: sport.isFeatured,
                  activeColor: const Color(0xFFD4A843),
                  onTap: onToggleFeatured,
                ),
                const SizedBox(width: 8),
                _ToggleChip(
                  label: 'Testing',
                  value: sport.isTesting,
                  activeColor: Colors.orange,
                  onTap: onToggleTesting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.value,
    required this.onTap,
    this.activeColor = Colors.green,
  });

  final String label;
  final bool value;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: value
              ? activeColor.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value
                ? activeColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: value ? activeColor : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _SportsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF1C1C1C),
        highlightColor: const Color(0xFF2A2A2A),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}