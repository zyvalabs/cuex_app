import 'package:cuex_app/features/shop/screens/players/widgets/my_breaks.dart';
import 'package:cuex_app/features/shop/screens/players/widgets/player_overview.dart';
import 'package:cuex_app/features/shop/screens/players/widgets/player_profile_header.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/appbar/tabbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../event_particapnts/widgets/my_events.dart';
import '../matches/widgets/my_matches_widget.dart';

class PlayerStatsScreen extends StatelessWidget {
  final UserModel? targetUser;
  const PlayerStatsScreen({super.key, this.targetUser});

  @override
  Widget build(BuildContext context) {
    // ✅ use targetUser if provided, else logged-in user
    final displayUser = targetUser ?? UserController.instance.user.value;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: TColors.peppercorn,
        appBar: TAppBar(
          showBackArrow: true,
          title: Text(
            targetUser != null ? '${displayUser.firstName}\'s Stats' : 'My Stats',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          showActions: false,
          showSkipButton: false,
        ),
        body: Column(
          children: [
            // ── Profile header ──────────────
            PlayerProfileHeader(user: displayUser),

            // ── Tab bar ─────────────────────
            const TTabBar(
              tabs: [
                Tab(child: Text('Overview')),
                Tab(child: Text('Breaks')),
                Tab(child: Text('Matches')),
                Tab(child: Text('Events')),
              ],
            ),

            // ── Tab content ─────────────────
            // ✅ pass displayUser.id to all widgets
            Expanded(
              child: TabBarView(
                children: [
                  PlayerOverviewWidget(userId: displayUser.id),
                  MyBreaksWidget(userId: displayUser.id),
                  MyMatchesWidget(playerId: displayUser.id),
                  MyEventsWidget(userId: displayUser.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}