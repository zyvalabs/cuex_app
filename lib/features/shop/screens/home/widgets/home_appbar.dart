import 'package:cuex_app/features/personalization/screens/setting/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../routes/routes.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../personalization/controllers/settings_controller.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../../personalization/screens/profile/profile.dart';
import '../../users/widgets/user_avatar_widget.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    final controller = Get.put(UserController());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TColors.june.withOpacity(0.12),
            TColors.peppercorn.withOpacity(0.0),
          ],
        ),
      ),
      child: TAppBar(
        title: GestureDetector(
          onTap: () => Get.to(() => const SettingsScreen()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting label ──────────────
              Text(
                TTexts.homeAppbarTitle,
                style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: TColors.grey,
                ),
              ),

              // ── User name ───────────────────
              Obx(() {
                if (controller.profileLoading.value) {
                  return const TShimmerEffect(width: 100, height: 16);
                }
                if (controller.user.value.id.isEmpty) {
                  return Text(
                    'Your Name',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .apply(color: TColors.white),
                  );
                }
                return Text(
                  controller.user.value.fullName.isNotEmpty
                      ? controller.user.value.fullName
                      : controller.user.value.phoneNumber.isNotEmpty
                      ? controller.user.value.phoneNumber
                      : 'Your Name',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .apply(color: TColors.white),
                );
              }),
            ],
          ),
        ),
        actions: [
          // // ── Notification bell ──────────────
          // GestureDetector(
          //   onTap: () => Get.toNamed(TRoutes.notification),
          //   child: Container(
          //     width: 36,
          //     height: 36,
          //     margin: const EdgeInsets.only(right: 8),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.06),
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.white.withOpacity(0.08),
          //       ),
          //     ),
          //     child: const Icon(
          //       Iconsax.notification,
          //       size: 17,
          //       color: Colors.white70,
          //     ),
          //   ),
          // ),

          // ── Avatar ────────────────────────
          Obx(() {
            final user = controller.user.value;
            return GestureDetector(
              onTap: () => Get.to(() => const ProfileScreen()),
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: controller.profileLoading.value
                    ? const TShimmerEffect(
                  width: 36,
                  height: 36,
                  radius: 36,
                )
                    : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TColors.june.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: UserAvatarWidget(
                    imageUrl: user.profilePicture,
                    fullName: user.fullName.isNotEmpty
                        ? user.fullName
                        : 'U',
                    radius: 18,
                  ),
                ),
              ),
            );
          }),
        ],
        showActions: true,
        showSkipButton: false,
      ),
    );
  }
}