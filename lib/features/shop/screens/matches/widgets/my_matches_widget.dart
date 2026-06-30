import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';


import '../../../../../common/widgets/matches/card/match_card.dart';
import '../../../../../common/widgets/shimmers/match_shimmer.dart';
import '../../../../../data/repositories/matches/matches_repository.dart';
import '../../../../../routes/routes.dart';
import '../../../../personalization/controllers/user_controller.dart';

import '../../../models/match_model.dart';
class MyMatchesWidget extends StatefulWidget {
  final String? playerId; // ✅ add
  const MyMatchesWidget({super.key, this.playerId}); // ✅ add

  @override
  State<MyMatchesWidget> createState() => _MyMatchesWidgetState();
}

class _MyMatchesWidgetState extends State<MyMatchesWidget>
    with AutomaticKeepAliveClientMixin {

  late final Future<List<MatchModel>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // ✅ use passed playerId or fallback to logged-in user
    final id = widget.playerId ?? UserController.instance.user.value.id;
    _future = MatchRepository.instance.fetchMatchesByPlayer(id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<List<MatchModel>>(
      future: _future, // ✅ cached
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const TMatchCardShimmer();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white38)),
          );
        }
        final matches = snapshot.data ?? [];
        if (matches.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports, color: Colors.white12, size: 48),
                SizedBox(height: 12),
                Text('No matches yet',
                    style: TextStyle(color: Colors.white38)),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
          child: Column(
            children: matches.map((match) => MatchCard(
              match: match,
              onTap: () => Get.toNamed(TRoutes.matchDetails, arguments: match),
            )).toList(),
          ),
        );
      },
    );
  }
}