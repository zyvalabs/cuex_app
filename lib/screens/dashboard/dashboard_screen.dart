import 'package:cuex_app/features/shop/screens/matches/widgets/my_matches_widget.dart';
import 'package:cuex_app/screens/matches/my_matches_screen.dart';
import 'package:flutter/material.dart';

import '../../core/utils/constants/app_colors.dart';
import '../../core/utils/constants/image_strings_name.dart';
import '../../core/widgets/cards/action_card.dart';

import '../../screens/events/events_screen.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../settings/settings.dart';
import '../stream/stream_match_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        titleWidget: Image.asset(AppImages.cueCam, height: 40),
        rightActions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Container(
            //   width: double.infinity,
            //   margin: const EdgeInsets.symmetric(horizontal: 8),
            //   padding: const EdgeInsets.symmetric(vertical: 8),
            //   decoration: BoxDecoration(
            //     color: Colors.black,
            //     borderRadius: BorderRadius.circular(2),
            //   ),
            //   child: Column(
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Text(
            //             'SEE EXAMPLES',
            //             style: TextStyle(color: AppColors.secondary, fontSize: 20, fontWeight: FontWeight.w800),
            //           ),
            //           const SizedBox(width: 8),
            //           const CircleAvatar(radius: 5, backgroundColor: Colors.red),
            //         ],
            //       ),
            //       const SizedBox(height: 4),
            //       Text(
            //         '(USERS VIDEO)',
            //         style: TextStyle(color: AppColors.secondary, fontSize: 15),
            //       ),
            //     ],
            //   ),
            // ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: StreamOptionCard(
                      title: 'CREATE A NEW LIVE STREAM',
                      subtitle: 'and score yourself',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyMatchesScreen()),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamOptionCard(
                      title: 'STREAM RANKED EVENTS',
                      subtitle: 'with automatic scoring',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventScreen()),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamOptionCard(
                      title: 'SCORE A MATCH',
                      subtitle: 'with automatic scoring',
                      onTap: () {
                        // TODO: navigate to tournament match setup
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}