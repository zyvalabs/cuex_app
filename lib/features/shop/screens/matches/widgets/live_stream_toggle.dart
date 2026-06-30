import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class LiveStreamToggle extends StatelessWidget {
  const LiveStreamToggle({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final RxBool enabled;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () => onChanged(!enabled.value),
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: enabled.value
              ? Colors.red.withOpacity(0.08)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: enabled.value
                ? Colors.red.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
            width: enabled.value ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: enabled.value
                    ? Colors.red.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: Icon(
                Iconsax.video_play,
                size: 20,
                color: enabled.value ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Streaming',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: enabled.value ? Colors.red : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enabled.value
                        ? 'YouTube broadcast will be created'
                        : 'Tap to enable live streaming',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled.value,
              onChanged: onChanged,
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    ));
  }
}