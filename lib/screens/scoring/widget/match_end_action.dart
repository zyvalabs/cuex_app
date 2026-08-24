import 'package:flutter/material.dart';
import '../../../controllers/frame_tracking_controller.dart';
import '../../../controllers/match_result_conrollers.dart';
import '../../../controllers/score sync/scoring_persistence_controller.dart';
import '../../../controllers/score_controller.dart';
import '../../matches/widgets/match_winner_sheet.dart';

/// Encapsulates the entire "end match" action — showing MatchWinnerSheet
/// pre-selected with whoever's leading, applying the result, and
/// persisting. Keeps this logic out of ScoringScreen entirely.
class MatchEndAction {
  static void trigger(
      BuildContext context, {
        required ScoreController score,
        required FrameTrackingController frames,
        required MatchResultController result,
        required ScoringPersistenceController persistence,
        required String side1Label,
        required String side2Label,
      }) {
    MatchWinnerSheet.show(
      context,
      side1Label: side1Label,
      side2Label: side2Label,
      side1FramesWon: frames.side1FramesWon.value,
      side2FramesWon: frames.side2FramesWon.value,
      onConfirm: (winningSide) {
        result.endMatch(winningSide: winningSide, scoreController: score, frameTracking: frames);
        persistence.persist();
      },
    );
  }
}