import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/dialog/coming_soon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../events/events_screen.dart';
import '../../news/news_list_screen.dart';
import '../../users/user_list_screen.dart';
import '../../venues/venue_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserController.instance.user.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CueX Admin'),
        actions: [
          IconButton(icon: const Icon(Iconsax.notification), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TSizes.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [TColors.primary, TColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.shield_tick, color: Colors.white, size: 36),
                  const SizedBox(height: TSizes.sm),
                  Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  Text(user.fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: TSizes.xs),
                  const Text('Admin Dashboard', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: TSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(child: _statCard(context, icon: Iconsax.building, label: 'Venues', value: '--', onTap: () => Get.to(() => const VenueListScreen()))),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(child: _statCard(context, icon: Iconsax.people, label: 'Players', value: '--', onTap: () => Get.to(() => const UserListScreen(roleFilter: AppRole.player)))),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(child: _statCard(context, icon: Iconsax.profile_2user, label: 'Partners', value: '--', onTap: () => Get.to(() => const UserListScreen(roleFilter: AppRole.partner)))),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(child: _statCard(context, icon: Iconsax.video_play, label: 'Matches', value: '--', onTap: () {})),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(child: _statCard(context, icon: Iconsax.calendar, label: 'Events', value: '--', onTap: () => Get.to(() => const EventsScreen(showBackArrow: true)))),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(child: _statCard(context, icon: Iconsax.chart, label: 'Analytics', value: '--', onTap: () => ComingSoonDialog.show(context, title: 'Analytics'))),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(child: _statCard(context, icon: Iconsax.paperclip, label: 'News', value: '--', onTap: () => Get.to(() => const NewsListScreen()))),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(child: _statCard(context, icon: Iconsax.user, label: 'Users', value: '--', onTap: () => Get.to(() => const UserListScreen()))),
              ],
            ),
            const Spacer(),
            Center(child: Text('More features coming soon', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, {required IconData icon, required String label, required String value, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: TColors.primary, size: 28),
            const SizedBox(width: TSizes.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}