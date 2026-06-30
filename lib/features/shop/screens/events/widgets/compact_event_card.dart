import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../controllers/event_controller.dart';
import '../../../models/event_model.dart';
import '../add_event_screen.dart';
import '../event_details.dart';

class CompactEventCard extends StatelessWidget {
  const CompactEventCard({super.key, required this.event, this.showActions = false});

  final EventModel event;
  final bool showActions;

  Color _statusColor() {
    switch (event.eventStatus) {
      case EventStatus.live: return Colors.red;
      case EventStatus.upcoming: return Colors.green;
      case EventStatus.completed: return Colors.grey;
    }
  }

  bool get _isUpcoming => event.eventStatus == EventStatus.upcoming;

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Event', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this event?\nThis action cannot be undone.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              EventController.instance.deleteEvent(event);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => EventDetailScreen(event: event)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: event.imageUrl.isNotEmpty
                      ? Image.network(
                    event.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                      : _placeholder(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(color: _statusColor(), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              event.eventStatus.value.toUpperCase(),
                              style: TextStyle(color: _statusColor(), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
                            ),
                            const Spacer(),
                            // Testing badge — admin only
                            if (event.isTesting)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                child: const Text('TEST', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.w700)),
                              ),
                            if (!event.isPublic)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                child: const Text('PRIVATE', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w700)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          event.name,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 12, color: Colors.white38),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(event.startDate),
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, size: 18, color: Colors.white24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Edit/Delete — only for upcoming + showActions
            if (showActions && _isUpcoming) ...[
              const Divider(color: Colors.white10, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() => AddEventScreen(venueId: event.venueId, event: event)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Iconsax.edit, size: 14, color: Colors.white70),
                            SizedBox(width: 4),
                            Text('Edit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.trash, size: 14, color: Colors.red),
                            SizedBox(width: 4),
                            Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFF222222),
      child: const Icon(Icons.sports, color: Colors.white24, size: 32),
    );
  }
}