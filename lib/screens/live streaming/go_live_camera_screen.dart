import 'package:cuex_app/screens/live%20streaming/widgets/battery_indicator.dart';
import 'package:cuex_app/screens/live%20streaming/widgets/match_data_builder.dart';
import 'package:cuex_app/screens/live%20streaming/widgets/network_speed.dart';
import 'package:cuex_app/screens/live%20streaming/widgets/timer_widget.dart';
import 'package:cuex_app/screens/live%20streaming/widgets/zoom_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/app_button.dart';
import '../../controllers/camera/camera_stream_controller.dart';
import '../../controllers/frame_tracking_controller.dart';
import '../../controllers/score sync/scoring_persistence_controller.dart';
import '../../controllers/score_controller.dart';
import '../../services/camera_permission_service.dart';

/// Go Live camera screen — always opens in landscape. Real match data is
/// passed in from MatchDetailsScreen. Live scoreboard values come from
/// ScoringPersistenceController (which pulls from local storage OR RTDB,
/// whichever has the freshest data) — and this screen keeps listening
/// for changes the whole time it's open, pushing every update straight
/// to the burned-in scoreboard overlay via updateScoreboard().
class GoLiveCameraScreen extends StatefulWidget {
  final String? matchId;
  final String sport;
  final String eventName;
  final String roundName;
  final List<String> side1Players;
  final List<String> side2Players;
  final String? teamNameA;
  final String? teamNameB;
  final int totalFrames;
  final String? rtmpUrl;
  final String? streamKey;

  const GoLiveCameraScreen({
    super.key,
    this.matchId,
    required this.sport,
    this.eventName = 'CueX Match',
    this.roundName = '',
    required this.side1Players,
    required this.side2Players,
    this.teamNameA,
    this.teamNameB,
    this.totalFrames = 5,
    this.rtmpUrl,
    this.streamKey,
  });

  @override
  State<GoLiveCameraScreen> createState() => _GoLiveCameraScreenState();
}

class _GoLiveCameraScreenState extends State<GoLiveCameraScreen> {
  final camera = Get.isRegistered<CameraStreamController>()
      ? Get.find<CameraStreamController>()
      : Get.put(CameraStreamController());
  final _permissionService = CameraPermissionService();

  // Always goes through ScoringPersistenceController — it already knows
  // how to load from local storage OR fall back to RTDB, and stays
  // live-subscribed for the whole session (same mechanism that fixed
  // the "second phone doesn't see updates" issue).
  final persistence = Get.isRegistered<ScoringPersistenceController>()
      ? Get.find<ScoringPersistenceController>()
      : Get.put(ScoringPersistenceController());

  ScoreController get _score => persistence.score;
  FrameTrackingController get _frames => persistence.frames;

  @override
  void initState() {
    super.initState();
    if (widget.matchId != null) {
      persistence.loadForMatch(widget.matchId!); // loads local OR falls back to RTDB, stays live-subscribed
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Push a scoreboard update every time any relevant value changes —
    // whether the change came from THIS device (if also scoring locally)
    // or from RTDB (another device scoring, synced via
    // ScoringPersistenceController's live subscription). Either way, the
    // burned-in overlay always reflects the true current score.
    ever(_score.side1Score, (_) => _pushScoreboardUpdate());
    ever(_score.side2Score, (_) => _pushScoreboardUpdate());
    ever(_score.side1CurrentBreak, (_) => _pushScoreboardUpdate());
    ever(_score.side2CurrentBreak, (_) => _pushScoreboardUpdate());
    ever(_score.side1HighestBreak, (_) => _pushScoreboardUpdate());
    ever(_score.side2HighestBreak, (_) => _pushScoreboardUpdate());
    ever(_score.activePlayer, (_) => _pushScoreboardUpdate());
    ever(_frames.side1FramesWon, (_) => _pushScoreboardUpdate());
    ever(_frames.side2FramesWon, (_) => _pushScoreboardUpdate());
  }

  void _pushScoreboardUpdate() {
    if (camera.isPreviewActive.value) {
      camera.updateScoreboard(_buildMatchData());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Properly sequenced cleanup — stop preview, reset orientation, THEN
  /// pop. Doing this in dispose() instead races: dispose() can't reliably
  /// await async native calls before the widget/PlatformView is torn down,
  /// which is what was leaving a stale black surface behind.
  Future<void> _onBackPressed() async {
    if (camera.isPreviewActive.value) {
      await camera.stopPreview();
    }
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (mounted) Navigator.of(context).pop();
  }

  /// Builds the matchData map with the EXACT keys ScoreboardManager
  /// expects, pulling live values via ScoringPersistenceController's
  /// score/frames controllers (already up to date from local storage
  /// or RTDB, whichever is freshest).
  Map<String, dynamic> _buildMatchData() {
    final side1Name = widget.teamNameA?.isNotEmpty == true
        ? widget.teamNameA!
        : (widget.side1Players.isNotEmpty ? widget.side1Players.join(' & ') : 'Player 1');
    final side2Name = widget.teamNameB?.isNotEmpty == true
        ? widget.teamNameB!
        : (widget.side2Players.isNotEmpty ? widget.side2Players.join(' & ') : 'Player 2');

    return buildScoreboardMatchData(
      score: _score,
      frames: _frames,
      side1Name: side1Name,
      side2Name: side2Name,
      eventName: widget.eventName,
      roundName: widget.roundName,
      totalFrames: widget.totalFrames,
    );
  }

  Future<void> _onStartPreviewTapped() async {
    final result = await _permissionService.requestCameraAndMicPermission();

    switch (result) {
      case PermissionResult.granted:
        await camera.startPreview(_buildMatchData());
        break;

      case PermissionResult.denied:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera and microphone access is required to go live.')),
          );
        }
        break;

      case PermissionResult.permanentlyDenied:
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'Camera and microphone access was denied. Please enable them in Settings to go live.',
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _permissionService.openAppSettingsPage();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        break;
    }
  }

  Future<void> _onGoLiveTapped() async {
    if (widget.rtmpUrl == null || widget.streamKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing RTMP URL or stream key for this match.')),
      );
      return;
    }

    final success = await camera.goLive(
      rtmpUrl: widget.rtmpUrl!,
      streamKey: widget.streamKey!,
      matchData: _buildMatchData(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(camera.lastError.value ?? 'Failed to start streaming.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // intercept system back so we can clean up first
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Camera preview — real native surface via PlatformView
              Positioned.fill(
                child: AndroidView(
                  viewType: 'com.cuex.app/camera_preview',
                  creationParams: const {},
                  creationParamsCodec: const StandardMessageCodec(),
                ),
              ),

              // Back button — top-left
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _onBackPressed,
                  ),
                ),
              ),

              // Status widgets — top-right, stacked
              const Positioned(
                top: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RecordingTimerWidget(),
                    SizedBox(height: 8),
                    NetworkSpeedWidget(),
                    SizedBox(height: 8),
                    BatteryIndicatorWidget(),
                  ],
                ),
              ),

              // Zoom control — right side, vertically centered
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: ZoomControlWidget(
                    onZoomIn: () => camera.zoomIn(),
                    onZoomOut: () => camera.zoomOut(),
                  ),
                ),
              ),

              // Bottom action button(s)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Obx(() {
                  if (!camera.isPreviewActive.value) {
                    return AppButton(text: 'Start Preview', onPressed: _onStartPreviewTapped);
                  }
                  if (!camera.isStreaming.value) {
                    return AppButton(text: 'Go Live', onPressed: _onGoLiveTapped);
                  }
                  return AppButton(
                    text: 'End Stream',
                    backgroundColor: Colors.red,
                    onPressed: () => camera.endStream(),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}