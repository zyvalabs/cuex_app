import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(TSizes.xl),
              decoration: const BoxDecoration(
                color: TColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.tick_circle, color: Colors.white, size: 60),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Text('Booking Confirmed!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text('Your table has been booked successfully', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed(TRoutes.home),
                child: const Text('Go Home'),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TextButton(
              onPressed: () => Get.toNamed(TRoutes.myBookings),
              child: const Text('View My Bookings'),
            ),
          ],
        ),
      ),
    );
  }
}