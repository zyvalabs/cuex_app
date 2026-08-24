import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/match_creation_controller.dart';
import '../../../../controllers/youtube_setup_controller.dart';
import '../../../../core/widgets/radio/radio_option.dart';

/// Start Now / Schedule for Later — full UI inline, wired to controller,
/// with real showDatePicker + showTimePicker.
class YoutubeScheduleSection extends StatelessWidget {
  const YoutubeScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<YoutubeSetupController>();

    return Obx(() {
      final isScheduled = controller.isScheduled.value;
      final scheduledDateTime = controller.youtubeScheduledStartTime.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Start Time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          RadioOptionTile(
            title: 'Start Now',
            subtitle: 'Go live immediately',
            isSelected: !isScheduled,
            onTap: () => controller.setScheduleMode(false),
          ),
          RadioOptionTile(
            title: 'Schedule for Later',
            subtitle: 'Pick a date and time',
            isSelected: isScheduled,
            onTap: () => controller.setScheduleMode(true),
          ),
          if (isScheduled) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date == null) return;

                if (!context.mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time == null) return;

                final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                controller.setScheduledDateTime(combined);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      scheduledDateTime != null
                          ? '${scheduledDateTime.day}/${scheduledDateTime.month}/${scheduledDateTime.year} — ${scheduledDateTime.hour}:${scheduledDateTime.minute.toString().padLeft(2, '0')}'
                          : 'Select date & time',
                      style: TextStyle(color: scheduledDateTime != null ? Colors.black : Colors.grey),
                    ),
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}