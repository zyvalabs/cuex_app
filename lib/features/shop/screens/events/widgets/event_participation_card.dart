import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/event_model.dart';
import '../../../models/event_participant_model.dart';
import '../event_details.dart';


class EventParticipationCard extends StatelessWidget {
  const EventParticipationCard({
    super.key,
    required this.participation,
    required this.event,
    this.isLast = false,
  });

  final EventParticipantModel participation;
  final EventModel? event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isValidUrl = event?.imageUrl.isNotEmpty == true &&
        event!.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        if (event != null) Get.to(() => EventDetailScreen(event: event!));
      },
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // ── Image ────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isValidUrl
                  ? CachedNetworkImage(
                imageUrl: event!.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
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
                  Text(
                    event?.name ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (event != null)
                    Row(
                      children: [
                        Icon(
                          Iconsax.calendar,
                          size: 10,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy')
                              .format(event!.startDate),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _StatusPill(
                        label: participation.status.toUpperCase(),
                        color: _participantStatusColor(participation.status),
                      ),
                      const SizedBox(width: 6),
                      _StatusPill(
                        label: participation.paymentStatus.toUpperCase(),
                        color: _paymentStatusColor(participation.paymentStatus),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Right ────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (event != null)
                  _EventStatusDot(status: event!.eventStatus),
                const SizedBox(height: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _participantStatusColor(String status) {
    switch (status) {
      case 'confirmed': return TColors.june;
      case 'registered': return Colors.blue;
      case 'withdrawn': return Colors.red;
      default: return Colors.white38;
    }
  }

  Color _paymentStatusColor(String status) {
    switch (status) {
      case 'paid': return TColors.june;
      case 'pending': return Colors.orange;
      case 'waived': return Colors.white38;
      default: return Colors.white38;
    }
  }

  Widget _placeholder() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(
      Iconsax.cup,
      size: 20,
      color: Colors.white.withOpacity(0.15),
    ),
  );
}

// ─────────────────────────────────────────────
// Status Pill
// ─────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Event Status Dot
// ─────────────────────────────────────────────

class _EventStatusDot extends StatelessWidget {
  const _EventStatusDot({required this.status});
  final EventStatus status;

  Color get _color {
    switch (status) {
      case EventStatus.live: return Colors.red;
      case EventStatus.upcoming: return TColors.june;
      case EventStatus.completed: return Colors.white38;
      default: return Colors.white38;
    }
  }

  String get _label {
    switch (status) {
      case EventStatus.live: return 'Live';
      case EventStatus.upcoming: return 'Upcoming';
      case EventStatus.completed: return 'Completed';
      }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: _color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}