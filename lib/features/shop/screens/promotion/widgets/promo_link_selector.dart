import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/promotion_controller.dart';

class PromoLinkSelector extends StatelessWidget {
  const PromoLinkSelector({
    super.key,
    required this.selectedLinkType,
    required this.selectedLinkRoute,
    required this.externalUrlController,
    required this.onLinkTypeChanged,
    required this.onRouteChanged,
  });

  final RxString selectedLinkType;
  final RxString selectedLinkRoute;
  final TextEditingController externalUrlController;
  final void Function(String) onLinkTypeChanged;
  final void Function(String) onRouteChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Link type toggle
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _TypeTab(
                label: 'In-App Page',
                icon: Iconsax.mobile,
                isSelected: selectedLinkType.value == 'internal',
                onTap: () => onLinkTypeChanged('internal'),
              ),
              _TypeTab(
                label: 'External URL',
                icon: Iconsax.global,
                isSelected: selectedLinkType.value == 'external',
                onTap: () => onLinkTypeChanged('external'),
              ),
            ],
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Internal — route dropdown
        if (selectedLinkType.value == 'internal') ...[
          Text(
            'Select Page',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              border:
              Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLinkRoute.value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1A1A),
                icon: const Icon(Iconsax.arrow_down,
                    size: 16, color: Colors.grey),
                items: PromotionController.destinations.map((d) {
                  return DropdownMenuItem<String>(
                    value: d['route'],
                    child: Row(
                      children: [
                        Icon(
                          _routeIcon(d['route']!),
                          size: 16,
                          color: TColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          d['label']!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onRouteChanged(val);
                },
              ),
            ),
          ),
        ],

        // External — URL input
        if (selectedLinkType.value == 'external') ...[
          TextFormField(
            controller: externalUrlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'External URL *',
              hintText: 'https://example.com',
              prefixIcon: Icon(Iconsax.global, size: 18),
            ),
          ),
        ],
      ],
    ));
  }

  IconData _routeIcon(String route) {
    switch (route) {
      case '/events':
        return Iconsax.cup;
      case '/matches':
        return Iconsax.video;

      case '/leaderboard':
        return Iconsax.chart;
      case '/news':
        return Iconsax.paperclip;
      default:
        return Iconsax.arrow_right;
    }
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}