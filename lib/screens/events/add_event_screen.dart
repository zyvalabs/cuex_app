import 'package:cuex_app/screens/events/widgets/event_format_section.dart';
import 'package:cuex_app/screens/events/widgets/event_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/event_creation_controller.dart';
import '../../core/model/sports_model.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../core/widgets/cards/sport_options_card.dart';
import '../../core/widgets/title/section_title_widget.dart';
import '../../widgets/common/custom_app_bar.dart';



/// Add Event screen — Step 1: Choose Sport, then Event Name + Format.
/// Same pattern as match creation, but ends with event name instead of players.
class AddEventScreen extends StatelessWidget {
  const AddEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EventCreationController>()
        ? Get.find<EventCreationController>()
        : Get.put(EventCreationController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'New Event',
        showBackButton: true,
        rightActions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => AppButton(
          text: controller.isSaving.value ? 'Creating Event...' : 'Create Event',
          isLoading: controller.isSaving.value,
          onPressed: controller.isEventSetupValid && !controller.isSaving.value
              ? () async {
            final eventId = await controller.createEvent();
            if (eventId != null) {
              if (context.mounted) {
                Navigator.pop(context); // back to Events list
              }
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(controller.saveError.value ?? 'Failed to create event')),
              );
            }
          }
              : null,
        )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const SectionTitleWidget(
                  title: 'Choose Sport',
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kSports.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final sport = kSports[index];
                    return Obx(() => SportOptionCard(
                      sportName: sport.name,
                      imagePath: sport.imagePath,
                      containerColor: Colors.white,
                      imageBackgroundColor: Colors.black,
                      textColor: Colors.black,
                      isSelected: controller.isSelected(sport),
                      onTap: () => controller.selectSport(sport),
                    ));
                  },
                ),
                const SizedBox(height: 24),

                const EventNameSection(),
                const SizedBox(height: 24),

                const EventFormatSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}