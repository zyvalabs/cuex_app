import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/dialog/coming_soon.dart';
import '../../../../common/widgets/stats/stat_card.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/role_guard.dart';
import '../../controllers/venue_controller.dart';

class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final venue = VenueController.instance.venue.value;

    return Scaffold(
      backgroundColor: TColors.peppercorn,
      appBar: TAppBar(
        showBackArrow: false,
        title: Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
        showActions: false,
        showSkipButton: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey.withOpacity(0.2), height: 1),
        ),
      ),
      body: RoleGuard(
        roles: [AppRole.partner, AppRole.admin],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Welcome
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Welcome back, ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                        TextSpan(text: venue.name.isNotEmpty ? venue.name : 'Partner', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Stats
              StatCardsGrid(
                stats: [
                  StatCardData(title: 'Total Tables', value: venue.tablesCount.toString(), icon: Iconsax.element_4, color: TColors.primary),
                  StatCardData(title: 'Active Matches', value: '0', icon: Iconsax.activity, color: Colors.orange),
                  StatCardData(title: 'Total Events', value: '0', icon: Iconsax.cup, color: Colors.purple),
                  StatCardData(title: 'Total Bookings', value: '0', icon: Iconsax.calendar_tick, color: TColors.success),
                ],
              ),

              /// Quick Actions
              Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: _quickAction(context, icon: Iconsax.tag, label: 'Manage Tables', onTap: () => Get.toNamed(TRoutes.tables, arguments: venue)),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: _quickAction(context, icon: Iconsax.discount_shape, label: 'Coupons', onTap: () => ComingSoonDialog.show(context, title: 'Coupons', message: 'Discount coupons for your venue. Coming soon!')),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: _quickAction(context, icon: Iconsax.calendar_tick, label: 'Bookings', onTap: () => ComingSoonDialog.show(context, title: 'Bookings', message: 'Manage your venue bookings. Coming soon!')),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: _quickAction(context, icon: Iconsax.chart, label: 'Analytics', onTap: () => ComingSoonDialog.show(context, title: 'Analytics', message: 'Detailed insights and reports for your venue. Coming soon!')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: TColors.primary, size: 20),
            const SizedBox(width: TSizes.sm),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}