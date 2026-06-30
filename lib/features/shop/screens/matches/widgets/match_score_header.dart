import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/matches/card/match_card.dart';
import '../../../controllers/matches_controller.dart';
import '../../../models/match_model.dart';

class MatchScoreHeader extends StatelessWidget {
  const MatchScoreHeader({super.key, required this.match});
  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: EdgeInsets.fromLTRB(isTablet ? 24 : 16, 16, isTablet ? 24 : 16, 0),
      child: Obx(() {
        final currentMatch = MatchController.instance.currentMatch.value;
        return MatchCard(match: currentMatch ?? match);
      }),
    );
  }
}