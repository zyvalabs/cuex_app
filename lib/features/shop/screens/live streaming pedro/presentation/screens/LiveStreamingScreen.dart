import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

import '../../../../../../common/widgets/date/date_timer.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../controllers/match_stat_controller.dart';
import '../../../../models/match_model.dart';
import '../controllers/audio_controller.dart';
import '../controllers/broadcast_controller.dart';
import '../controllers/camera_controller.dart';
import '../controllers/preview_controller.dart';
import '../controllers/stream_controller.dart';
import '../controllers/streaming_coordinator.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/streaming_app_bar.dart';
import '../widgets/streaming_error_dialog.dart';
import '../widgets/streaming_overlay.dart';

class LiveStreamingScreen extends StatefulWidget {
  final MatchModel match;

  const LiveStreamingScreen({
    super.key,
    required this.match,
  });

  @override
  State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen>
    with WidgetsBindingObserver {

  StreamSubscription? _scoringSubscription;
  Worker? _scoreWorker;

  late PreviewController previewController;
  late LiveStreamController streamController;
  late StreamingCoordinator coordinator;

  final isCameraSurfaceReady = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// Initialize controllers safely (no duplicates)
    previewController = Get.isRegistered<PreviewController>()
        ? Get.find<PreviewController>()
        : Get.put(PreviewController());

    streamController = Get.isRegistered<LiveStreamController>()
        ? Get.find<LiveStreamController>()
        : Get.put(LiveStreamController());

    if (!Get.isRegistered<AudioController>()) {
      Get.put(AudioController());
    }

    if (!Get.isRegistered<CameraController>()) {
      Get.put(CameraController());
    }

    if (!Get.isRegistered<BroadcastController>()) {
      Get.put(BroadcastController());
    }
    if (!Get.isRegistered<MatchStatsController>()) {
      Get.put(MatchStatsController());
    }
    /// Coordinator with tag (per match)
    coordinator = Get.isRegistered<StreamingCoordinator>(tag: widget.match.id)
        ? Get.find<StreamingCoordinator>(tag: widget.match.id)
        : Get.put(StreamingCoordinator(matchId: widget.match.id), tag: widget.match.id);

    /// Force landscape for streaming
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    /// After UI builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCameraSurface();
      _setupScoringListener();

      // Auto-start preview if stream is active
      if (streamController.isStreaming.value && !previewController.isActive.value) {
        coordinator.startPreview();
      }
    });
  }

  /// Wait for camera surface
  Future<void> _checkCameraSurface() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      isCameraSurfaceReady.value = true;
      dev.log('Camera surface ready');
    }
  }

  /// Listen to scoring updates safely
  void _setupScoringListener() {
    try {
      final matchStatsController = Get.find<MatchStatsController>();

      _scoreWorker = ever(matchStatsController.currentFrame, (frame) {
        if (frame != null && frame.winnerId == null) {
          dev.log('Scoring update received');
          coordinator.updateScoreboard();
        }
      });
    } catch (e) {
      dev.log('Scoring listener error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    /// Cancel subscriptions
    _scoringSubscription?.cancel();
    _scoreWorker?.dispose();

    /// Delete controllers safely
    if (Get.isRegistered<PreviewController>()) {
      Get.delete<PreviewController>();
    }

    if (Get.isRegistered<LiveStreamController>()) {
      Get.delete<LiveStreamController>();
    }

    if (Get.isRegistered<AudioController>()) {
      Get.delete<AudioController>();
    }

    if (Get.isRegistered<CameraController>()) {
      Get.delete<CameraController>();
    }

    if (Get.isRegistered<BroadcastController>()) {
      Get.delete<BroadcastController>();
    }

    if (Get.isRegistered<MatchStatsController>()) {
      Get.delete<MatchStatsController>();
    }

    /// Reset orientation back to normal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.peppercorn,
      body: SafeArea(
        child: Stack(
          children: [
            /// Camera preview
            const CameraPreviewWidget(),

            /// Logo overlay when preview not active
            Obx(() {
              if (!previewController.isActive.value) {
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo/cuex_cam_logo.png',
                          width: 200,
                          height: 200,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.videocam,
                            size: 100,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(() => Text(
                          isCameraSurfaceReady.value
                              ? 'Ready to stream'
                              : 'Initializing camera...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        )),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            /// Top bar
            StreamingAppBar(matchId: widget.match.id),

            /// Live duration timer
            Obx(() {
              if (streamController.isStreaming.value) {
                return Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: DurationTimer(
                      duration:
                      streamController.streamHealth.value?.duration ?? 0,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            /// Bottom controls
            StreamingOverlay(
              matchId: widget.match.id,
              matchName: widget.match.matchStatus ?? 'Match',
              isCameraSurfaceReady: isCameraSurfaceReady,
            ),

            /// Preview errors
            Obx(() {
              final error = previewController.error.value;
              if (error != null && error.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    showStreamingErrorDialog(context, error);
                    previewController.error.value = null;
                  }
                });
              }
              return const SizedBox.shrink();
            }),

            /// Stream errors
            Obx(() {
              final error = streamController.error.value;
              if (error != null && error.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    showStreamingErrorDialog(context, error);
                    streamController.error.value = null;
                  }
                });
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
