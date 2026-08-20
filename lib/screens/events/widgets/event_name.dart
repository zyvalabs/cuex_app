import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/event_creation_controller.dart';

/// Event name input — wired directly to EventCreationController.
class EventNameSection extends StatelessWidget {
  const EventNameSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventCreationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller.eventNameController,
          onChanged: (_) => controller.onEventNameChanged(),
          decoration: InputDecoration(
            hintText: 'e.g. Snooker 900 — Finals',
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}