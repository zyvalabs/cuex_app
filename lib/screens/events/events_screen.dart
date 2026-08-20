import 'package:cuex_app/screens/events/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/events_ist_controller.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'add_event_screen.dart';

import 'event_details_screen.dart';

/// Events screen — real Firestore-backed event list, newest first.
class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EventsListController>()
        ? Get.find<EventsListController>()
        : Get.put(EventsListController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'Events',
        showBackButton: true,
        rightActions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: AppButton(
          text: 'Add Event',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEventScreen()),
            );
            controller.fetchEvents(); // refresh list after returning
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error.value != null) {
              return Center(child: Text('Failed to load events: ${controller.error.value}'));
            }

            if (controller.events.isEmpty) {
              return const Center(child: Text('No events yet — add your first one!'));
            }

            return ListView.separated(
              itemCount: controller.events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = controller.events[index];
                return EventCard(
                  eventName: event.eventName,
                  sport: event.format.isNotEmpty ? '${event.sport} · ${event.format}' : event.sport,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)),
                    );
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}