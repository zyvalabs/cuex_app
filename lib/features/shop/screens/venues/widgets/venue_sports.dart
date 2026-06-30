import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../../../common/widgets/sports/sports_grid.dart';

import '../../../controllers/add_venue_controller.dart';
import '../../../controllers/venue_controller.dart';

class VenueSportsStep extends StatefulWidget {
  const VenueSportsStep({super.key});

  @override
  State<VenueSportsStep> createState() => _VenueSportsStepState();
}

class _VenueSportsStepState extends State<VenueSportsStep> {
  @override
  void initState() {
    super.initState();
    VenueController.instance.fetchAllSports();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AddEditVenueController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Sports', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text('Select all sports available at your venue', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(() {
            final sports = VenueController.instance.allSports;
            if (sports.isEmpty) return const Center(child: CircularProgressIndicator());
            return SportsGrid(
              sports: sports,
              selectedSportIds: c.selectedSportIds.toList(), // convert RxList to List
              multiSelect: true,
              onTap: (sport) => c.onSportSelected(sport),
            );
          }),
        ],
      ),
    );
  }
}