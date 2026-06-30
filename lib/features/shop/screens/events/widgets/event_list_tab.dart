import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../controllers/event_controller.dart';
import '../../../models/event_model.dart';
import 'compact_event_card.dart';

class EventListTab extends StatelessWidget {
  const EventListTab({
    super.key,
    required this.status,
    required this.searchQuery,
    required this.showActions,
    required this.onRefresh,
  });

  final EventStatus status;
  final String searchQuery;
  final bool showActions;
  final Future<void> Function() onRefresh;

  List<EventModel> _filtered(List<EventModel> all) {
    if (searchQuery.isNotEmpty) {
      return all
          .where((e) =>
          e.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return all.where((e) => e.eventStatus == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();

    return Obx(() {
      // ── Shimmer ──────────────────────────
      if (controller.isLoading.value) {
        return const _EventShimmer();
      }

      final filtered = _filtered(controller.allEvents.toList());

      // ── Empty ─────────────────────────────
      if (filtered.isEmpty) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          color: TColors.june,
          backgroundColor: const Color(0xFF1A1A1A),
          child: ListView(
            children: [
              SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.calendar,
                          size: 28,
                          color: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'No results for "$searchQuery"'
                            : 'No ${status.value} events',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // ── List ──────────────────────────────
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: TColors.june,
        backgroundColor: const Color(0xFF1A1A1A),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
          itemCount: filtered.length,
          itemBuilder: (_, i) => CompactEventCard(
            event: filtered[i],
            showActions: showActions,
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _EventShimmer extends StatelessWidget {
  const _EventShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            TShimmerEffect(width: 64, height: 64, radius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TShimmerEffect(width: 50, height: 9, radius: 4),
                  const SizedBox(height: 6),
                  TShimmerEffect(
                      width: double.infinity, height: 13, radius: 4),
                  const SizedBox(height: 5),
                  TShimmerEffect(width: 120, height: 13, radius: 4),
                  const SizedBox(height: 6),
                  TShimmerEffect(width: 80, height: 9, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}