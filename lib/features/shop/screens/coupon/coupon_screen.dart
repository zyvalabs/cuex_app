import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/role_guard.dart';
import '../../controllers/coupons_controller.dart';
import 'add_coupon_screen.dart';
class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponsController());
    controller.fetchVenueCoupons();

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Coupons', style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
      ),
      body: const Center(
        child: Text('Welcome to Coupons', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: RoleGuard(
        roles: [AppRole.admin, AppRole.partner],
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddCouponScreen()),
            icon: const Icon(Iconsax.add),
            label: const Text('Add Coupon'),
          ),
        ),
      ),
    );

  }
}