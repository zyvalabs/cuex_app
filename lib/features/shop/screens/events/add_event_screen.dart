import 'package:cuex_app/features/shop/screens/events/widgets/event_prizes_section.dart';
import 'package:cuex_app/features/shop/screens/events/widgets/event_settings_toggle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../common/widgets/sports/sports_grid.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/venue_controller.dart';
import '../../models/event_model.dart';
import '../../../personalization/controllers/user_controller.dart';
import 'widgets/event_image_picker.dart';
import 'widgets/event_date_picker.dart';
import 'widgets/event_format_selector.dart';
import 'widgets/event_prize_section.dart';

// ─────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────

class AddEventScreen extends StatefulWidget {
  final String venueId;
  final EventModel? event;
  const AddEventScreen({super.key, required this.venueId, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final controller = EventController.instance;
  final _sportsLoading = true.obs;

  bool get isEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    _init();
    if (isEdit) controller.prefill(widget.event!);
  }

  Future<void> _init() async {
    _sportsLoading.value = true;
    try {
      final venueController = VenueController.instance;
      final isAdmin = UserController.instance.user.value.role == AppRole.admin;
      if (isAdmin) {
        await venueController.fetchAllSports();
      } else {
        await venueController.fetchVenueSports(venueController.venue.value.sportIds);
      }
    } finally {
      _sportsLoading.value = false;
    }
  }

  @override
  void dispose() {
    if (!isEdit) controller.resetForm();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isEdit) {
      final updated = widget.event!;
      updated.name = controller.nameController.text.trim();
      updated.description = controller.descriptionController.text.trim();
      updated.maxParticipants = int.tryParse(controller.maxParticipantsController.text.trim()) ?? 0;
      updated.startDate = controller.selectedStartDate.value!;
      updated.endDate = controller.selectedEndDate.value!;
      updated.registrationDeadline = controller.selectedRegistrationDeadline.value!;
      updated.format = controller.selectedFormat.value;
      updated.participantType = controller.selectedParticipantType.value;
      updated.isFeatured = controller.isFeatured.value;
      updated.isVerified = controller.isVerified.value;
      updated.isPublic = controller.isPublic.value;
      updated.isTesting = controller.isTesting.value;
      updated.entryFee = double.tryParse(controller.entryFeeController.text.trim());
      updated.prizePool = double.tryParse(controller.prizePoolController.text.trim());
      updated.sportId = controller.selectedSportId.value.isNotEmpty
          ? controller.selectedSportId.value
          : null;
      updated.updatedAt = DateTime.now();
      await controller.updateEvent(updated, context);
    } else {
      await controller.submitEvent(widget.venueId, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = UserController.instance.user.value.role == AppRole.admin;

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(isEdit ? 'Edit Event' : 'Add Event'),
        showActions: false,
        showSkipButton: false,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──────────────────────────
              const _SectionLabel('Event Image'),
              const EventImagePicker(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // ── Basic Info ─────────────────────
              const _SectionLabel('Event Details'),
              const _EventBasicFields(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // ── Sport ──────────────────────────
              const _SectionLabel('Sport'),
              _SportSection(sportsLoading: _sportsLoading),
              const SizedBox(height: TSizes.spaceBtwSections),

              // ── Format ─────────────────────────
              const _SectionLabel('Format & Type'),
              const EventFormatSelector(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // ── Dates ──────────────────────────
              const _SectionLabel('Dates'),
              const _EventDatesSection(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // ── Submit ─────────────────────────
              _SubmitButton(isEdit: isEdit, onSubmit: _submit),
              const SizedBox(height: TSizes.defaultSpace),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

// ─────────────────────────────────────────────
// Basic Fields
// ─────────────────────────────────────────────

class _EventBasicFields extends StatelessWidget {
  const _EventBasicFields();

  @override
  Widget build(BuildContext context) {
    final controller = EventController.instance;
    return Column(
      children: [
        TextFormField(
          controller: controller.nameController,
          decoration: const InputDecoration(
            labelText: 'Event Name *',
            prefixIcon: Icon(Iconsax.cup, size: 18),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (v) => v == null || v.isEmpty ? 'Enter event name' : null,
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        TextFormField(
          controller: controller.descriptionController,
          maxLines: 3,
          maxLength: 300,
          decoration: const InputDecoration(
            labelText: 'Description',
            prefixIcon: Icon(Iconsax.document_text, size: 18),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        TextFormField(
          controller: controller.maxParticipantsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Max Participants (Optional)',
            prefixIcon: Icon(Iconsax.people, size: 18),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Sport Section with Shimmer
// ─────────────────────────────────────────────

class _SportSection extends StatelessWidget {
  const _SportSection({required this.sportsLoading});
  final RxBool sportsLoading;

  @override
  Widget build(BuildContext context) {
    final controller = EventController.instance;

    return Obx(() {
      // Show shimmer while loading
      if (sportsLoading.value) return const _SportsShimmer();

      final isAdmin = UserController.instance.user.value.role == AppRole.admin;
      final sports = isAdmin
          ? VenueController.instance.allSports
          : VenueController.instance.venueSports;

      return SportsGrid(
        sports: sports,
        selectedSportIds: controller.selectedSportId.value.isNotEmpty
            ? [controller.selectedSportId.value]
            : [],
        onTap: (sport) => controller.selectedSportId.value = sport.id,
      );
    });
  }
}

// ─────────────────────────────────────────────
// Sports Shimmer
// ─────────────────────────────────────────────

class _SportsShimmer extends StatelessWidget {
  const _SportsShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(right: 10),
          width: (MediaQuery.of(context).size.width - 48) / 3,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2C2C2C)),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 7,
                child: Center(
                  child: TShimmerEffect(width: 40, height: 40, radius: 8),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF222222),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TShimmerEffect(width: 48, height: 10, radius: 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dates Section
// ─────────────────────────────────────────────

class _EventDatesSection extends StatelessWidget {
  const _EventDatesSection();

  @override
  Widget build(BuildContext context) {
    final controller = EventController.instance;
    return Column(
      children: [
        EventDatePicker(
          label: 'Start Date',
          date: controller.selectedStartDate,
          onTap: () => controller.pickStartDate(context),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        EventDatePicker(
          label: 'End Date',
          date: controller.selectedEndDate,
          onTap: () => controller.pickEndDate(context),
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        EventDatePicker(
          label: 'Registration Deadline',
          date: controller.selectedRegistrationDeadline,
          onTap: () => controller.pickRegistrationDeadline(context),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Submit Button
// ─────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isEdit, required this.onSubmit});
  final bool isEdit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final controller = EventController.instance;
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Text(isEdit ? 'Update Event' : 'Create Event'),
      ),
    ));
  }
}