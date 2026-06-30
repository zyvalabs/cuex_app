import 'dart:async';
import 'package:cuex_app/features/shop/screens/live%20streaming%20pedro/presentation/controllers/remote_streaming.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

import '../../../../../../common/widgets/date/date_timer.dart';
import '../../../../../../remote/remote_streaming_app_bar.dart';
import '../../../../../../remote/remote_streaming_overlay.dart';
import '../../../../../../utils/constants/colors.dart';
import '../controllers/audio_controller.dart';
import '../controllers/broadcast_controller.dart';
import '../controllers/camera_controller.dart';
import '../controllers/preview_controller.dart';
import '../controllers/stream_controller.dart';

import '../widgets/camera_preview_widget.dart';
import '../widgets/streaming_error_dialog.dart';

class StreamingScreen extends StatefulWidget {
  const StreamingScreen({super.key});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen>
    with WidgetsBindingObserver {

  late PreviewController previewController;
  late LiveStreamController streamController;
  late RemoteStreamCoordinator coordinator;

  final isCameraSurfaceReady = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    previewController = Get.isRegistered<PreviewController>()
        ? Get.find<PreviewController>()
        : Get.put(PreviewController());

    streamController = Get.isRegistered<LiveStreamController>()
        ? Get.find<LiveStreamController>()
        : Get.put(LiveStreamController());

    if (!Get.isRegistered<AudioController>()) Get.put(AudioController());
    if (!Get.isRegistered<CameraController>()) Get.put(CameraController());
    if (!Get.isRegistered<BroadcastController>()) Get.put(BroadcastController());

    coordinator = Get.isRegistered<RemoteStreamCoordinator>()
        ? Get.find<RemoteStreamCoordinator>()
        : Get.put(RemoteStreamCoordinator());

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCameraSurface();
      if (streamController.isStreaming.value && !previewController.isActive.value) {
        coordinator.startPreview();
      }
    });
  }

  Future<void> _checkCameraSurface() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      isCameraSurfaceReady.value = true;
      dev.log('Camera surface ready');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (Get.isRegistered<PreviewController>()) Get.delete<PreviewController>();
    if (Get.isRegistered<LiveStreamController>()) Get.delete<LiveStreamController>();
    if (Get.isRegistered<AudioController>()) Get.delete<AudioController>();
    if (Get.isRegistered<CameraController>()) Get.delete<CameraController>();
    if (Get.isRegistered<BroadcastController>()) Get.delete<BroadcastController>();

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
            const CameraPreviewWidget(),

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

            RemoteStreamingAppBar(matchId: ''),

            Obx(() {
              if (streamController.isStreaming.value) {
                return Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: DurationTimer(
                      duration: streamController.streamHealth.value?.duration ?? 0,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            RemoteStreamingOverlay(
              matchId: '',
              matchName: 'Waiting...',
              isCameraSurfaceReady: isCameraSurfaceReady,
            ),

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