import 'package:cuex_app/features/shop/screens/dashbaord/partner_dashboard.dart';
import 'package:cuex_app/features/shop/screens/events/events_screen.dart';
import 'package:cuex_app/features/shop/screens/home/scan_screen.dart';
import 'package:cuex_app/features/shop/screens/matches/matches_screen.dart';
import 'package:cuex_app/features/shop/screens/venues/venue_screen.dart';
import 'package:cuex_app/utils/constants/colors.dart';
import 'package:cuex_app/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import 'features/personalization/controllers/user_controller.dart';
import 'features/personalization/screens/setting/settings.dart';
import 'features/shop/screens/home/admin_home_screen/admin_home.dart';
import 'features/shop/screens/home/home_screen.dart';

// ── Green accent ────────────────────────────
const _kGreen = Color(0xFF2ECC71);
const _kGreenBg = Color(0x1A2ECC71); // 10% green

// ─────────────────────────────────────────────
// HomeMenu
// ─────────────────────────────────────────────

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserController>()) Get.put(UserController());
    final controller = Get.put(AppScreenController());

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Obx(() => _CueXNavBar(
        destinations: controller.destinations,
        selectedIndex: controller.selectedMenu.value,
        onTap: (i) {
          HapticFeedback.lightImpact();
          controller.selectedMenu.value = i;
        },
      )),
      body: Obx(() => controller.screens[controller.selectedMenu.value]),
    );
  }
}

// ─────────────────────────────────────────────
// Custom Nav Bar — floating pill style (B)
// ─────────────────────────────────────────────

class _CueXNavBar extends StatelessWidget {
  const _CueXNavBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<_NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        12,
        6,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: TColors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: destinations.asMap().entries.map((entry) {
            final i = entry.key;
            final dest = entry.value;
            final isSelected = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      dest.lottie != null
                          ? Lottie.asset(
                        dest.lottie!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      )
                          : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          dest.icon,
                          key: ValueKey(isSelected),
                          size: 28,
                          color: isSelected ? TColors.june : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dest.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? _kGreen : Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Dot indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 4 : 0,
                        height: isSelected ? 4 : 0,
                        decoration: const BoxDecoration(
                          color: _kGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Nav Destination Model
// ─────────────────────────────────────────────

class _NavDestination {
  final IconData icon;
  final String label;
  final String? lottie; // ✅ optional lottie path
  const _NavDestination({required this.icon, required this.label, this.lottie});
}
// ─────────────────────────────────────────────
// App Screen Controller
// ─────────────────────────────────────────────

class AppScreenController extends GetxController {
  static AppScreenController get instance => Get.find();

  final Rx<int> selectedMenu = 0.obs;

  @override
  void onInit() {
    if (!Get.isRegistered<UserController>()) Get.put(UserController());
    super.onInit();
  }

  AppRole get _role {
    try {
      return UserController.instance.user.value.role;
    } catch (e) {
      return AppRole.player;
    }
  }

  List<Widget> get screens {
    switch (_role) {
      case AppRole.admin:
        return [
          const AdminDashboardScreen(),
          const MatchesScreen(),
          const VenueScreen(),
          const EventsScreen(showBackArrow: false),
          const SettingsScreen(),
        ];
      case AppRole.partner:
        return [
          const PartnerDashboardScreen(),
          const MatchesScreen(),
          const EventsScreen(showBackArrow: false),
          const SettingsScreen(),
        ];
      case AppRole.player:
        return [
          const HomeScreen(),
          const MatchesScreen(),
          const ScanScreen(),
          const EventsScreen(showBackArrow: false),
          const SettingsScreen(),
        ];
    }
  }

  List<_NavDestination> get destinations {
    switch (_role) {
      case AppRole.admin:
        return const [
          _NavDestination(icon: Iconsax.home, label: 'Home'),
          _NavDestination(icon: Iconsax.video_play, label: 'Matches'),
          _NavDestination(icon: Iconsax.building_3, label: 'Venues'),
          _NavDestination(icon: Iconsax.calendar, label: 'Events'),
          _NavDestination(icon: Iconsax.user, label: 'Profile'),
        ];
      case AppRole.partner:
        return const [
          _NavDestination(icon: Iconsax.home_2, label: 'Home'),
          _NavDestination(icon: Iconsax.video_play, label: 'Matches'),
          _NavDestination(icon: Iconsax.calendar, label: 'Events'),
          _NavDestination(icon: Iconsax.user, label: 'Profile'),
        ];
      case AppRole.player:
        return const [
          _NavDestination(icon: Iconsax.home, label: 'Home'),
          _NavDestination(icon: Iconsax.video_play, label: 'Live', lottie: 'assets/logos/live.json'), // ✅
          _NavDestination(icon: Iconsax.scan, label: 'Scan'),
          _NavDestination(icon: Iconsax.cup, label: 'Events'),
          _NavDestination(icon: Iconsax.user, label: 'Profile'),
        ];
    }
  }
}