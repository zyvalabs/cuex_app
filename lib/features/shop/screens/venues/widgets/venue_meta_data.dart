import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../models/venue_model.dart';


class TVenueMetaData extends StatelessWidget {
  const TVenueMetaData({super.key, required this.venue});

  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);
    final isOpen = venue.status == 'open';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Status Badge
        Row(
          children: [
            TRoundedContainer(
              radius: TSizes.sm,
              padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
              backgroundColor: isOpen ? TColors.success.withOpacity(0.2) : TColors.error.withOpacity(0.2),
              child: Text(
                isOpen ? 'Open' : 'Closed',
                style: Theme.of(context).textTheme.labelLarge!.apply(color: isOpen ? TColors.success : TColors.error),
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),

            /// Rating
            const Icon(Iconsax.star1, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text('${venue.rating} (${venue.totalRatings})', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

        /// Venue Name
        Text(venue.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

        /// Address
        Row(
          children: [
            const Icon(Iconsax.location, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(child: Text(venue.address, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey))),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

        /// Tables Count
        Row(
          children: [
            const Icon(Iconsax.grid_1, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${venue.tablesCount} Tables', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}