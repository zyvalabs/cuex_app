import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/event_model.dart';
import '../event_details.dart';

class TEventCardVertical extends StatelessWidget {
  const TEventCardVertical({super.key, required this.event});
  final EventModel event;

  Color get _statusColor {
    switch (event.eventStatus) {
      case EventStatus.live: return Colors.red;
      case EventStatus.upcoming: return Colors.green;
      case EventStatus.completed: return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (event.eventStatus) {
      case EventStatus.live: return 'LIVE';
      case EventStatus.upcoming: return 'UPCOMING';
      case EventStatus.completed: return 'COMPLETED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => EventDetailScreen(event: event)),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Full image
            Stack(
              children: [
                // Image
                event.imageUrl.isNotEmpty
                    ? Image.network(
                  event.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),

                // Gradient overlay at bottom of image
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Status badge — top left
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (event.eventStatus == EventStatus.live)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          _statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Entry fee — bottom left on image
                if (event.entryFee != null && event.entryFee! > 0)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Text(
                      '₹${event.entryFee!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFD4A843),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),

            // Details below image
            Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Event name
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Start date
                  Row(
                    children: [
                      const Icon(Iconsax.calendar, size: 11, color: Color(0xFFD4A843)),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(event.startDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFD4A843),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Registration deadline
                  Row(
                    children: [
                      const Icon(Iconsax.clock, size: 11, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Reg. by ${DateFormat('dd MMM').format(event.registrationDeadline)}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFF2A2A2A),
      child: const Icon(Iconsax.cup, size: 40, color: Colors.grey),
    );
  }
}

/// Horizontal scrollable featured events list
class FeaturedEventsSection extends StatelessWidget {
  const FeaturedEventsSection({super.key, required this.events});
  final List<EventModel> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => TEventCardVertical(event: events[i]),
      ),
    );
  }
}