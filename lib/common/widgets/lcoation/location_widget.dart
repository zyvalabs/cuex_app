import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../features/shop/controllers/venue_controller.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = VenueController.instance;

    return Obx(() {
      final city = controller.city.value;
      final subLocality = controller.subLocality.value;
      final isDetecting = city == 'Detecting...';
      final isFailed = city == 'Set Location';

      return GestureDetector(
        onTap: () async {
          if (isFailed) {
            // Retry or open settings
            _showLocationDialog(context, controller);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Location icon ──────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isFailed ? Iconsax.location_slash : Iconsax.location,
                key: ValueKey(isFailed),
                color: isFailed ? Colors.white24 : const Color(0xFF2ECC71),
                size: 16,
              ),
            ),
            const SizedBox(width: 6),

            // ── Text or spinner ────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subtle label
                Text(
                  isDetecting
                      ? 'Locating...'
                      : isFailed
                      ? 'Tap to set'
                      : 'Your location',
                  style: TextStyle(
                    fontSize: 10,
                    color: isFailed ? Colors.white24 : Colors.white38,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),

                // City row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDetecting)
                      const SizedBox(
                        width: 80,
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.white12,
                          color: Color(0xFF2ECC71),
                        ),
                      )
                    else
                      Text(
                        subLocality.isNotEmpty
                            ? '$subLocality, $city'
                            : city,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isFailed ? Colors.white38 : Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isFailed ? Colors.white24 : Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────
  // Location dialog — retry or open settings
  // ─────────────────────────────────────────
  void _showLocationDialog(BuildContext context, VenueController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.location,
                size: 28,
                color: Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Location Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Allow location access to find venues and events near you.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white38,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Retry button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await controller.fetchLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Allow Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Open settings button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Get.back();
                  await controller.locationService.openAppSettings();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Open Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}