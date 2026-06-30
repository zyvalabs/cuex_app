import 'package:cuex_app/features/shop/screens/venues/widgets/venue_amenities.dart';
import 'package:cuex_app/features/shop/screens/venues/widgets/venue_image.dart';
import 'package:cuex_app/features/shop/screens/venues/widgets/venue_info_step.dart';
import 'package:cuex_app/features/shop/screens/venues/widgets/venue_location_step.dart';
import 'package:cuex_app/features/shop/screens/venues/widgets/venue_sports.dart';
import 'package:cuex_app/features/shop/screens/venues/widgets/venue_timing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../controllers/add_venue_controller.dart';
import '../../models/venue_model.dart';

class AddEditVenueScreen extends StatelessWidget {
  const AddEditVenueScreen({super.key, this.venue});
  final VenueModel? venue;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEditVenueController());
    if (venue != null) controller.prefill(venue!);
    final isEdit = venue != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Venue' : 'Add Venue')),
      body: Obx(() => Column(
        children: [
          _StepIndicatorB(current: controller.step.value, total: controller.totalSteps, label: controller.stepLabels[controller.step.value]),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              switch (controller.step.value) {
                case 0: return const VenueInfoStep();
                case 1: return const VenueLocationStep();
                case 2: return const VenueTimingsStep();
                case 3: return const VenueSportsStep();
                case 4: return const VenueImagesStep();
                case 5: return const VenueAmenitiesStep();
                default: return Center(child: Text('Step ${controller.step.value + 1}: ${controller.stepLabels[controller.step.value]}'));
              }
            }),
          ),
        ],
      )),
      bottomNavigationBar: Obx(() => Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Row(
          children: [
            if (controller.step.value > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.prevStep,
                  icon: const Icon(Iconsax.arrow_left, size: 16),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
              ),
            if (controller.step.value > 0) const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (controller.step.value < controller.totalSteps - 1) {
                    controller.nextStep();
                  } else {
                    controller.saveVenue(context, existingVenue: venue);
                  }
                },
                icon: Icon(controller.step.value == controller.totalSteps - 1 ? Iconsax.tick_circle : Iconsax.arrow_right, size: 16),
                label: Text(controller.step.value == controller.totalSteps - 1 ? (isEdit ? 'Update Venue' : 'Save Venue') : 'Next'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
class _StepIndicatorB extends StatelessWidget {
  const _StepIndicatorB({required this.current, required this.total, required this.label});
  final int current;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(total, (i) {
              final isDone = i < current;
              final isActive = i == current;
              return Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                    height: isActive ? 5 : 3,
                    decoration: BoxDecoration(
                      color: isDone
                          ? primary.withOpacity(0.4)
                          : isActive
                          ? primary
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _stepSubtitle(current),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${current + 1} / $total',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(total, (i) {
              final isDone = i < current;
              final isActive = i == current;
              return Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: isActive ? 24 : 8,
                      height: 8,
                      margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: isDone
                            ? primary.withOpacity(0.35)
                            : isActive
                            ? primary
                            : Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _stepSubtitle(int step) {
    const subtitles = [
      'Name, description & contact',
      'Address & map location',
      'Opening & closing hours',
      'What sports are available',
      'Facilities & photos',
      'Instagram, Facebook & more',
    ];
    return step < subtitles.length ? subtitles[step] : '';
  }
}