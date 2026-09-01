import 'package:cuex_app/screens/scoring/widget/frame_control_button.dart';
import 'package:cuex_app/screens/scoring/widget/frame_history_table.dart';
import 'package:cuex_app/screens/scoring/widget/match_end_action.dart';
import 'package:cuex_app/screens/scoring/widget/player_switch_toggle.dart';
import 'package:cuex_app/screens/scoring/widget/score_control.dart';
import 'package:cuex_app/screens/scoring/widget/snooker_balls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/score sync/scoring_persistence_controller.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../matches/widgets/match_control_button.dart';
import '../matches/widgets/match_start_action.dart';
import '../players/player_score_box.dart';


/// Thin screen — just layout, stacking sections and delegating actions.
/// All state lives in ScoreController/FrameTrackingController/
/// MatchResultController; all save/sync logic lives in
/// ScoringPersistenceController; sheet-trigger logic lives in
/// MatchStartAction/MatchEndAction.
class ScoringScreen extends StatefulWidget {
  final String? matchId;
  final String sport;
  final String matchType;
  final List<String> side1Players;
  final List<String> side2Players;
  final String? teamNameA;
  final String? teamNameB;

  const ScoringScreen({
    super.key,
    this.matchId,
    required this.sport,
    required this.matchType,
    required this.side1Players,
    required this.side2Players,
    this.teamNameA,
    this.teamNameB,
  });

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  final persistence = Get.isRegistered<ScoringPersistenceController>()
      ? Get.find<ScoringPersistenceController>()
      : Get.put(ScoringPersistenceController());

  @override
  void initState() {
    super.initState();
    persistence.setScoreboardContext(
      side1Name: widget.teamNameA?.isNotEmpty == true
          ? widget.teamNameA!
          : (widget.side1Players.isNotEmpty ? widget.side1Players.join(' & ') : 'Player 1'),
      side2Name: widget.teamNameB?.isNotEmpty == true
          ? widget.teamNameB!
          : (widget.side2Players.isNotEmpty ? widget.side2Players.join(' & ') : 'Player 2'),
      eventName: 'CueX Match', // TODO: pass real event name if this match belongs to an event
      roundName: '',
      totalFrames: 5, // TODO: pass real bestOfFrames value from match format
    );
    if (widget.matchId != null) {
      persistence.loadForMatch(widget.matchId!);
    }
  }

  String get _side1Label => widget.teamNameA?.isNotEmpty == true
      ? widget.teamNameA!
      : (widget.side1Players.isNotEmpty ? widget.side1Players[0] : 'Side A');

  String get _side2Label => widget.teamNameB?.isNotEmpty == true
      ? widget.teamNameB!
      : (widget.side2Players.isNotEmpty ? widget.side2Players[0] : 'Side B');

  @override
  Widget build(BuildContext context) {
    final score = persistence.score;
    final frames = persistence.frames;
    final result = persistence.result;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        backgroundColor: AppColors.green,
        title: 'Scoring',
        showBackButton: true,
        rightActions: [
          IconButton(icon: const Icon(Icons.qr_code), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final otherLabel = score.activePlayer.value == 1 ? _side2Label : _side1Label;
              return PlayerSwitchToggle(
                otherPlayerName: otherLabel,
                onSwitch: () {
                  score.toggleActivePlayer();
                  persistence.persist();
                },
              );
            }),
            const SizedBox(height: 12),
            Obx(() => MatchControlButton(
              isMatchStarted: score.isMatchStarted.value,
              onPressed: () {
                if (score.isMatchStarted.value) {
                  MatchEndAction.trigger(
                    context,
                    score: score,
                    frames: frames,
                    result: result,
                    persistence: persistence,
                    side1Label: _side1Label,
                    side2Label: _side2Label,
                  );
                } else {
                  MatchStartAction.trigger(
                    context,
                    score: score,
                    persistence: persistence,
                    side1Label: _side1Label,
                    side2Label: _side2Label,
                  );
                }
              },
            )),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                final side1Column = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PlayerScoreBox(
                      playerNames: widget.side1Players,
                      teamName: widget.teamNameA,
                      score: score.side1Score.value,
                      isActive: score.isActive(1),
                      onTap: () {
                        score.setActivePlayer(1);
                        persistence.persist();
                      },
                    ),
                    if (widget.sport == 'Pool') ...[
                      const SizedBox(height: 8),
                      ScoreControl(
                        onIncrement: () {
                          score.incrementSide1();
                          persistence.persist();
                        },
                        onDecrement: () {
                          score.decrementSide1();
                          persistence.persist();
                        },
                      ),
                    ],
                  ],
                );

                final side2Column = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PlayerScoreBox(
                      playerNames: widget.side2Players,
                      teamName: widget.teamNameB,
                      score: score.side2Score.value,
                      isActive: score.isActive(2),
                      onTap: () {
                        score.setActivePlayer(2);
                        persistence.persist();
                      },
                    ),
                    if (widget.sport == 'Pool') ...[
                      const SizedBox(height: 8),
                      ScoreControl(
                        onIncrement: () {
                          score.incrementSide2();
                          persistence.persist();
                        },
                        onDecrement: () {
                          score.decrementSide2();
                          persistence.persist();
                        },
                      ),
                    ],
                  ],
                );

                final breaker = score.breakingPlayer.value ?? 1;
                final leftColumn = breaker == 1 ? side1Column : side2Column;
                final rightColumn = breaker == 1 ? side2Column : side1Column;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: leftColumn),
                    const SizedBox(width: 12),
                    Expanded(child: rightColumn),
                  ],
                );
              }),
              const SizedBox(height: 24),
              if (widget.sport == 'Snooker')
                Obx(() => Opacity(
                  opacity: frames.isFrameActive.value ? 1 : 0.4,
                  child: IgnorePointer(
                    ignoring: !frames.isFrameActive.value,
                    child: SnookerBalls(
                      onBallTapped: (points) {
                        score.addPointsToActive(points);
                        persistence.persist();
                      },
                    ),
                  ),
                )),
              const SizedBox(height: 20),
              Obx(() => FrameControlButtons(
                isFrameActive: frames.isFrameActive.value,
                onUndo: () {
                  score.undo();
                  persistence.persist();
                },
                onReset: () {
                  score.resetCurrentFrame();
                  persistence.persist();
                },
                onStartOrEndFrame: () {
                  if (frames.isFrameActive.value) {
                    frames.endFrame(score);
                  } else {
                    frames.startFrame();
                  }
                  persistence.persist();
                },
              )),
              const SizedBox(height: 24),
              Obx(() {
                final breakerIsSide1 = (score.breakingPlayer.value ?? 1) == 1;
                return FrameHistoryTable(
                  breakerName: breakerIsSide1 ? _side1Label : _side2Label,
                  otherName: breakerIsSide1 ? _side2Label : _side1Label,
                  frames: frames.completedFrames,
                  isCurrentFrameActive: frames.isFrameActive.value,
                  currentFrameNumber: frames.currentFrameNumber.value,
                  currentSide1Score: score.side1Score.value,
                  currentSide2Score: score.side2Score.value,
                  currentSide1Break: score.side1HighestBreak.value,
                  currentSide2Break: score.side2HighestBreak.value,
                  breakerIsSide1: breakerIsSide1,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}