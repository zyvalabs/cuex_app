import 'package:cuex_app/screens/settings/stream_settings.dart';
import 'package:cuex_app/screens/settings/widgets/settings_menu_item.dart';
import 'package:flutter/material.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../features/personalization/controllers/user_controller.dart';
import '../../features/shop/screens/events/events_screen.dart';
import '../../utils/constants/sizes.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';

import '../events/events_screen.dart';
import '../matches/my_matches_screen.dart';
import '../players/player_card.dart';


/// Settings/Profile screen — logged-in user info + menu items.
/// onTap just prints for now — will connect real navigation/actions later.
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'Settings',
        showBackButton: false,
        rightActions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dummy data for now — will wire to real Firebase Auth/Firestore user later.
              const PlayerCard(
                name: 'Tanveer',
                email: 'tanveer@example.com',
                phoneNumber: '+91 98765 43210',
              ),
              const SizedBox(height: 20),

              SettingsMenuItem(
                icon: Icons.sports_score,
                label: 'My Matches',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyMatchesScreen()),
                  );
                },
              ),
              SettingsMenuItem(
                icon: Icons.emoji_events_outlined,
                label: 'My Events',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EventScreen()),
                  );
                },
              ),
              SettingsMenuItem(
                icon: Icons.settings_input_antenna,
                label: 'Stream Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StreamSettingsScreen()),
                  );
                },
              ),
              SettingsMenuItem(
                icon: Icons.help_outline,
                label: 'FAQ',
                onTap: () => print('🟠 FAQ tapped'),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              // SizedBox(
              //     width: double.infinity,
              //     child: OutlinedButton(onPressed: () => controller.logout(), child: const Text('Logout'))),
              // const SizedBox(height: TSizes.spaceBtwSections * 5.5),
              SettingsMenuItem(
                icon: Icons.logout,
                label: 'Logout',
                showChevron: false,
                onTap: () =>  controller.logout(),
              ),
              SettingsMenuItem(
                icon: Icons.delete_outline,
                label: 'Delete Account',
                iconColor: Colors.red,
                labelColor: Colors.red,
                showChevron: false,
                onTap: () => print('🟠 Delete Account tapped'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
