import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../controllers/add_venue_controller.dart';


class VenueAmenitiesStep extends StatelessWidget {
  const VenueAmenitiesStep({super.key});

  static final amenities = [
    const {'label': 'WiFi', 'icon': Iconsax.wifi},
    const {'label': 'Parking', 'icon': Iconsax.car},
    const {'label': 'AC', 'icon': Iconsax.wind},
    const {'label': 'Canteen', 'icon': Iconsax.coffee},
    const {'label': 'Washroom', 'icon': Iconsax.drop},
    {'label': 'Seating Area', 'icon': Iconsax.add},
    const {'label': 'CCTV', 'icon': Iconsax.security},
    const {'label': 'Water Dispenser', 'icon': Iconsax.cup},
    const {'label': 'Locker', 'icon': Iconsax.lock},
    const {'label': 'Changing Room', 'icon': Iconsax.profile_circle},
    const {'label': 'First Aid', 'icon': Iconsax.health},
    const {'label': 'Spectator Area', 'icon': Iconsax.people},
    const {'label': 'Scoreboard', 'icon': Iconsax.chart},
    const {'label': 'Equipment Rental', 'icon': Iconsax.box},
    const {'label': 'Coaching', 'icon': Iconsax.teacher},
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AddEditVenueController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amenities', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text('Select all facilities available at your venue', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(() => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: amenities.map((a) {
              final label = a['label'] as String;
              final icon = a['icon'] as IconData;
              final isSelected = c.selectedAmenities.contains(label);
              return GestureDetector(
                onTap: () => c.onAmenitySelected(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(Iconsax.tick_circle5, size: 14, color: Theme.of(context).primaryColor),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: TSizes.defaultSpace),
        ],
      ),
    );
  }
}