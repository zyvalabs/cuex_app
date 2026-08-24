import 'package:cuex_app/screens/events/widgets/event_match_list_item.dart';
import 'package:cuex_app/screens/events/widgets/event_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/event_matches_controller.dart';
import '../../controllers/match_creation_controller.dart';
import '../../controllers/match_setup_controller.dart';
import '../../core/model/event_model.dart';
import '../../core/model/sports_model.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../matches/match_detail_screen.dart';
import '../matches/match_setup_screen.dart';

/// Shows event details recap + list of matches created under this event.
class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final controller = Get.isRegistered<EventMatchesController>()
      ? Get.find<EventMatchesController>()
      : Get.put(EventMatchesController());

  @override
  void initState() {
    super.initState();
    controller.fetchMatches(widget.event.id!);
  }

  Future<void> _addMatch() async {
    final matchSetupController = Get.isRegistered<MatchSetupController>()
        ? Get.find<MatchSetupController>()
        : Get.put(MatchSetupController());

    // Also ensure MatchCreationController exists — needed later for the
    // final save step (platform choice + createMatch()).
    if (!Get.isRegistered<MatchCreationController>()) {
      Get.put(MatchCreationController());
    }

    final sport = kSports.firstWhere(
          (s) => s.name == widget.event.sport,
      orElse: () => kSports.first,
    );

    matchSetupController.presetFromEvent(eventIdValue: widget.event.id!, sport: sport);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MatchSetupScreen()),
    );

    controller.fetchMatches(widget.event.id!); // refresh list after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'Event Details',
        showBackButton: true,
        rightActions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: AppButton(text: 'Add Match', onPressed: _addMatch),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EventSummaryCard(event: widget.event),
              const SizedBox(height: 20),
              const Text('Matches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.error.value != null) {
                    return Center(child: Text('Failed to load matches: ${controller.error.value}'));
                  }

                  if (controller.matches.isEmpty) {
                    return const Center(
                      child: Text('No matches yet — add the first one!', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final match = controller.matches[index];
                      return EventMatchListItem(
                        match: match,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: match)),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}