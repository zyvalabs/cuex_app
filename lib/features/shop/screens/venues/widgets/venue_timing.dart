import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../../../common/widgets/time/time.dart';
import '../../../controllers/add_venue_controller.dart';

class VenueTimingsStep extends StatelessWidget {
  const VenueTimingsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AddEditVenueController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opening Hours', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: TSizes.spaceBtwItems),
          TTimePicker(
            label: 'Opening Time',
            time: c.openTime,
            onChanged: (val) => c.openTime.value = val,
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TTimePicker(
            label: 'Closing Time',
            time: c.closeTime,
            onChanged: (val) => c.closeTime.value = val,
          ),
        ],
      ),
    );
  }
}