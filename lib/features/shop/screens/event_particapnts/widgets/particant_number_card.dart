import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/event_registration_controller.dart';
import '../event_particapants_screen.dart';

class ParticipantNumberCard extends StatelessWidget {
  final String eventId;
  final int maxParticipants;

  const ParticipantNumberCard({
    super.key,
    required this.eventId,
    required this.maxParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventParticipantController>();
    controller.getParticipantCount(eventId);

    return Obx(() {
      final registered = controller.participantCount.value;
      final slotsLeft = maxParticipants - registered;
      final percentage = maxParticipants > 0
          ? (registered / maxParticipants).clamp(0.0, 1.0)
          : 0.0;
      final progressColor = _progressColor(percentage);

      return GestureDetector(
        onTap: () => Get.to(() => EventParticipantsScreen(
          eventId: eventId,
          showCreateMatch: false,
        )),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.people,
                            size: 14, color: Colors.white54),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PARTICIPANTS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Iconsax.arrow_right_3,
                      size: 16, color: Colors.white24),
                ],
              ),
              const SizedBox(height: 16),

              // Count + progress row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Count
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$registered',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: maxParticipants > 0
                              ? ' / $maxParticipants'
                              : ' registered',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Slots left badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: slotsLeft > 0
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: slotsLeft > 0
                            ? Colors.green.withOpacity(0.4)
                            : Colors.red.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      maxParticipants == 0
                          ? 'Open'
                          : slotsLeft > 0
                          ? '$slotsLeft slots left'
                          : 'FULL',
                      style: TextStyle(
                        color: slotsLeft > 0 ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              if (maxParticipants > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.white10,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}% filled',
                      style: TextStyle(
                          color: progressColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Tap to view all',
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Color _progressColor(double percentage) {
    if (percentage < 0.5) return Colors.green;
    if (percentage < 0.8) return Colors.orange;
    return Colors.red;
  }
}