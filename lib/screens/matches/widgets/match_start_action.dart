import 'package:flutter/material.dart';

import '../../../controllers/score sync/scoring_persistence_controller.dart';
import '../../../controllers/score_controller.dart';
import '../../scoring/widget/breaking_player_sheet.dart';


/// Encapsulates the entire "start match" action — building side labels,
/// showing BreakingPlayerSheet, and applying the result to ScoreController
/// + persisting. Keeps this logic out of ScoringScreen entirely.
class MatchStartAction {
  static void trigger(
      BuildContext context, {
        required ScoreController score,
        required ScoringPersistenceController persistence,
        required String side1Label,
        required String side2Label,
      }) {
    BreakingPlayerSheet.show(
      context,
      side1Label: side1Label,
      side2Label: side2Label,
      onConfirm: (selectedSide) {
        score.setBreakingPlayer(selectedSide);
        score.toggleMatchStarted();
        persistence.persist();
      },
    );
  }
}