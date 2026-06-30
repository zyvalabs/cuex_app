import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../data/repositories/events/event_repository.dart';
import '../../../../../data/repositories/events/events_participants.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../models/event_model.dart';
import '../../events/event_details.dart';


class MyEventsWidget extends StatefulWidget {
  final String? userId; // ✅ optional — fallback to logged-in user
  const MyEventsWidget({super.key, this.userId});

  @override
  State<MyEventsWidget> createState() => _MyEventsWidgetState();
}

class _MyEventsWidgetState extends State<MyEventsWidget>
    with AutomaticKeepAliveClientMixin {

  // ✅ cached future
  late Future<List<EventModel>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = _fetchEvents();
  }

  Future<List<EventModel>> _fetchEvents() async {
    // ✅ use passed userId or fallback to logged-in user
    final userId = widget.userId ?? UserController.instance.user.value.id;

    final participations = await Get.put(EventParticipantRepository())
        .fetchParticipantsByUser(userId);

    if (participations.isEmpty) return [];

    final eventIds = participations.map((p) => p.eventId).toSet().toList();

    final events = await Future.wait(
      eventIds.map((id) => EventRepository.instance
          .fetchSingleItem(id)
          .catchError((_) => null)),
    );

    return events.whereType<EventModel>().toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchEvents();
    });
  }

  Color _statusColor(EventStatus status) {
    switch (status) {
      case EventStatus.live: return Colors.red;
      case EventStatus.upcoming: return TColors.june;
      case EventStatus.completed: return Colors.white38;
      default: return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<List<EventModel>>(
      future: _future,
      builder: (context, snapshot) {
        // ── Shimmer ──────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _EventsShimmer();
        }

        // ── Error ─────────────────────────
        if (snapshot.hasError) {
          return _ErrorState(onRefresh: _refresh);
        }

        final events = snapshot.data ?? [];

        // ── Empty ─────────────────────────
        if (events.isEmpty) {
          return _EmptyState(onRefresh: _refresh);
        }

        // ── List ──────────────────────────
        return RefreshIndicator(
          onRefresh: _refresh,
          color: TColors.june,
          backgroundColor: const Color(0xFF1C1C1C),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
            child: Column(
              children: events.map((event) => _EventCard(
                event: event,
                statusColor: _statusColor(event.eventStatus),
              )).toList(),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Event Card
// ─────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.statusColor});
  final EventModel event;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final isValidUrl =
        event.imageUrl.isNotEmpty && event.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () => debugPrint('🎯 event tapped: ${event.name}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // ── Image ────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isValidUrl
                  ? CachedNetworkImage(
                imageUrl: event.imageUrl,
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
                  // Status
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        event.eventStatus.value.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Name
                  Text(
                    event.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 10,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(event.startDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 18,
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
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Iconsax.calendar, size: 24, color: Colors.white12),
  );
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _EventsShimmer extends StatelessWidget {
  const _EventsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
      child: Column(
        children: List.generate(
          5,
              (_) => Container(
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
                      TShimmerEffect(width: 50, height: 10, radius: 4),
                      const SizedBox(height: 6),
                      TShimmerEffect(width: double.infinity, height: 13, radius: 4),
                      const SizedBox(height: 5),
                      TShimmerEffect(width: 100, height: 10, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: const Icon(Iconsax.calendar, size: 28, color: Colors.white24),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Events Yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Events you join will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.refresh, size: 13, color: TColors.june),
                  const SizedBox(width: 5),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TColors.june,
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
}

// ─────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.warning_2, size: 28, color: Colors.red),
          ),
          const SizedBox(height: 12),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pull down to try again',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.refresh, size: 13, color: TColors.june),
                  const SizedBox(width: 5),
                  Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TColors.june,
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
}