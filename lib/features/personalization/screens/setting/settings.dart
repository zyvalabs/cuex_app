
import 'package:cuex_app/features/personalization/screens/setting/policy_screen.dart';
import 'package:cuex_app/features/personalization/screens/setting/support_screen.dart';
import 'package:cuex_app/features/personalization/screens/setting/terms_use_screen.dart';
import 'package:cuex_app/features/shop/screens/news/news_list_screen.dart';
import 'package:cuex_app/features/shop/screens/players/player_stat_screen.dart';
import 'package:cuex_app/features/shop/screens/sports/sport_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/list_tiles/settings_menu_tile.dart';
import '../../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../home_menu.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/role_guard.dart';
import '../../../shop/controllers/venue_controller.dart';
import '../../../shop/screens/events/my_events.dart';
import '../../../shop/screens/live streaming pedro/presentation/screens/youtube_streaming.dart';
import '../../../shop/screens/matches/create_match_screen.dart';
import '../../../shop/screens/matches/matches_screen.dart';
import '../../../shop/screens/players/player_qr_screen.dart';
import '../../../shop/screens/promotion/promotion_list.dart';
import '../../../shop/screens/streaming/streaming_credits_screen.dart';
import '../../../shop/screens/venues/venue_qr_screen.dart';
import '../../controllers/user_controller.dart';
import '../profile/profile.dart';
import 'upload_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    print('👤 Role: ${UserController.instance.user.value.role}');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offAll(const HomeMenu());
        }
      },
      child: Scaffold(
        backgroundColor: TColors.black,
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// -- Header
              TPrimaryHeaderContainer(
                child: Column(
                  children: [
                    /// AppBar
                    TAppBar(
                      title: Text('Profile', style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white)),
                      showActions: false,
                      showSkipButton: false,
                      showBackArrow: false,
                    ),

                    /// User Profile Card
                    TUserProfileTile(onPressed: () => Get.to(() => const ProfileScreen())),
                    const SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
              ),

              /// -- Profile Body
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// -- Account  Settings
                    const TSectionHeading(title: 'Account Settings', showActionButton: false),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    RoleGuard(
                      roles: [AppRole.player],
                      child: TSettingsMenuTile(
                        icon: Iconsax.chart,
                        title: 'My Stats',
                        subTitle: 'View your game statistics and performance',
                        onTap: () => Get.to(() => const PlayerStatsScreen()),
                      ),
                    ),
                    RoleGuard(roles: [AppRole.player], child:
                    TSettingsMenuTile(
                      icon: Iconsax.video_play,
                      title: 'Go Live',
                      subTitle: 'Create and stream a live match',
                      onTap: () => Get.to(() => CreateMatchScreen(eventId: '',isPractice: true,)),
                    ),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.camera,
                      title: 'Live Streaming',
                      subTitle:'Connect and manage your YouTube stream',
                      onTap: () => Get.to(() => const YouTubeStreamingScreen()),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.camera,
                      title: 'Streaming Credits',
                      subTitle:'Connect and manage your YouTube stream',
                      onTap: () => Get.to(() => const StreamingCreditsScreen()),
                    ),
                    RoleGuard(
                      roles: [AppRole.player, AppRole.partner],
                      child: TSettingsMenuTile(
                        icon: Iconsax.video_play,
                        title: 'My Matches',
                        subTitle: 'View your live, upcoming & completed matches',
                        onTap: () => Get.to(() => MatchesScreen(
                          playerId: UserController.instance.user.value.id,
                          showBackArrow: true,
                        )),
                      ),
                    ),
                    RoleGuard(
                      roles: [AppRole.player],
                      child: TSettingsMenuTile(
                        icon: Iconsax.scan_barcode,
                        title: 'My QR Code',
                        subTitle: 'Share your profile QR to join matches',
                        onTap: () => Get.to(() => const PlayerQRScreen()),
                      ),
                    ),
                    RoleGuard(
                      roles: [AppRole.player],
                      child: TSettingsMenuTile(
                        icon: Iconsax.cup,
                        title: 'My Events',
                        subTitle: 'View events you have registered for',
                        onTap: () => Get.to(() => const MyEventsScreen()),
                      ),
                    ),
                    RoleGuard(
                      roles: [AppRole.admin],
                      child: TSettingsMenuTile(
                        icon: Iconsax.calendar_tick,
                        title: 'My Sports',
                        subTitle: 'View Sports',
                        onTap: () => Get.to(() => const SportsManagementScreen()),
                      ),
                    ),
                    RoleGuard(
                      roles: [AppRole.partner],
                      child: TSettingsMenuTile(
                        icon: Iconsax.scan_barcode,
                        title: 'Venue QR Code',
                        subTitle: 'Share your venue QR code',
                        onTap: () => Get.to(() => const VenueQRScreen()),
                      ),
                    ),

                    RoleGuard(
                      roles: [AppRole.admin, AppRole.partner],
                      child: TSettingsMenuTile(
                        icon: Iconsax.grid_1,
                        title: 'Table Management',
                        subTitle: 'Manage tables for your venue',
                        onTap: () {
                          print('🏢 Venue: ${VenueController.instance.venue.value.id}');
                          Get.toNamed(TRoutes.tables, arguments: VenueController.instance.venue.value);
                        },
                      ),
                    ),
                    RoleGuard(
                      roles: [AppRole.admin],
                      child: TSettingsMenuTile(
                        icon: Iconsax.image,
                        title: 'Promotions',
                        subTitle: 'Manage home screen promotions',
                        onTap: () => Get.to(() => const PromoManagementScreen()),
                      ),
                    ),

                    // TSettingsMenuTile(
                    //   icon: Iconsax.calendar_tick,
                    //   title: 'My Bookings',
                    //   subTitle: 'View and manage your bookings',
                    //   onTap: () => Get.toNamed(TRoutes.myBookings),
                    // ),
                    RoleGuard(
                      roles: [AppRole.admin, AppRole.partner],
                      child: TSettingsMenuTile(
                        icon: Iconsax.crown,
                        title: 'Events Management',
                        subTitle: 'Manage events for your venue',
                        onTap: () => Get.toNamed(TRoutes.events),
                      ),
                    ),
                    RoleGuard(
                      roles: [AppRole.admin],
                      child: TSettingsMenuTile(
                        icon: Iconsax.video_play,
                        title: 'News & Updates',
                        subTitle: 'Manage News & Updates',
                        onTap: () => Get.to(() => NewsListScreen()),
                      ),
                    ),
                    // TSettingsMenuTile(
                    //   icon: Iconsax.discount_shape,
                    //   title: 'My Coupons',
                    //   subTitle: 'List of all the discounted coupons',
                    //   onTap: () => Get.toNamed(TRoutes.coupon),
                    // ),
                    // TSettingsMenuTile(
                    //   icon: Iconsax.notification,
                    //   title: 'Notifications',
                    //   subTitle: 'Set any kind of notification message',
                    //   onTap: () => Get.toNamed(TRoutes.notification),
                    // ),
                    // const TSettingsMenuTile(
                    //     icon: Iconsax.security_card,
                    //     title: 'Account Privacy',
                    //     subTitle: 'Manage data usage and connected accounts'),

                    /// -- App Settings
                    const SizedBox(height: TSizes.spaceBtwSections),
                    const TSectionHeading(title: 'App Settings', showActionButton: false),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TSettingsMenuTile(
                      icon: Iconsax.security_card,
                      title: 'Privacy Policy',
                      subTitle: 'Read our privacy policy and terms of service',
                      onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.document_text,
                      title: 'Terms of Service',
                      subTitle: 'Read our terms and conditions',
                      onTap: () => Get.to(() => const TermsOfUseScreen()),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.support1,
                      title: 'Contact Us',
                      subTitle: 'Get help from our support team',
                      onTap: () =>  Get.to(() => const HelpSupportScreen()),
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.star1,
                      title: 'Rate CueX',
                      subTitle: 'Enjoying CueX? Leave us a review',
                      onTap: () async {
                        final url = Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.cuex_app',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    // TSettingsMenuTile(
                    //   icon: Iconsax.location,
                    //   title: 'Geolocation',
                    //   subTitle: 'Set recommendation based on location',
                    //   trailing: Switch(value: true, onChanged: (value) {}),
                    // ),
                    // TSettingsMenuTile(
                    //   icon: Iconsax.security_user,
                    //   title: 'Safe Mode',
                    //   subTitle: 'Search result is safe for all ages',
                    //   trailing: Switch(value: false, onChanged: (value) {}),
                    // ),
                    // TSettingsMenuTile(
                    //   icon: Iconsax.image,
                    //   title: 'HD Image Quality',
                    //   subTitle: 'Set image quality to be seen',
                    //   trailing: Switch(value: false, onChanged: (value) {}),
                    // ),

                    /// -- Logout Button
                    const SizedBox(height: TSizes.spaceBtwSections),
                    SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(onPressed: () => controller.logout(), child: const Text('Logout'))),
                    const SizedBox(height: TSizes.spaceBtwSections * 5.5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}