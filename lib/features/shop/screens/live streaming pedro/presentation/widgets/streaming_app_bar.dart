import 'package:cuex_app/features/shop/screens/live%20streaming%20pedro/presentation/widgets/quality_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../../../../common/widgets/buttons/streaming_icon_button.dart';
import '../../../../../../utils/helpers/streaming_utils.dart';
import '../controllers/audio_controller.dart';
import '../controllers/camera_controller.dart';
import '../controllers/preview_controller.dart';
import '../controllers/stream_controller.dart';
import '../controllers/streaming_coordinator.dart';
import 'auto_reconnect.dart';
import 'connection_status_badge.dart';

class StreamingAppBar extends StatelessWidget {
  final String matchId;

  const StreamingAppBar({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    final coordinator = Get.find<StreamingCoordinator>(tag: matchId);
    final audioController = Get.find<AudioController>();
    final cameraController = Get.find<CameraController>();
    final previewController = Get.find<PreviewController>();
    final streamController = Get.find<LiveStreamController>();

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Back button
          StreamingIconButton(
            icon: Icons.arrow_back,
            onTap: () async {
              final shouldPop = await handleStreamingBackPress(
                context: context,
                matchId: matchId,
              );
              if (shouldPop && context.mounted) {
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
                await Future.delayed(const Duration(milliseconds: 200));
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 8),

          // Camera switch
          StreamingIconButton(
            icon: Icons.flip_camera_android,
            onTap: () => coordinator.switchCamera(),
          ),
          const SizedBox(width: 8),

          // Settings
          StreamingIconButton(
            icon: Icons.settings,
            onTap: () => showQualitySelectorDialog(context),
          ),
          const SizedBox(width: 8),

          // Microphone
          Obx(() => StreamingIconButton(
            icon: audioController.isMuted.value ? Icons.mic_off : Icons.mic,
            iconColor: audioController.isMuted.value ? Colors.red : Colors.white,
            isEnabled: previewController.isActive.value,
            onTap: () => coordinator.toggleAudio(),
          )),
          const SizedBox(width: 8),

          // // Auto focus indicator
          // Obx(() => StreamingIconButton(
          //   icon: cameraController.isAutoFocusEnabled.value
          //       ? Icons.center_focus_strong
          //       : Icons.center_focus_weak,
          //   iconColor: cameraController.isAutoFocusEnabled.value ? Colors.green : Colors.grey,
          //   onTap: () => coordinator.toggleAutoFocus(),
          // )),

          const SizedBox(width: 8),
          StreamingIconButton(
            icon: Icons.zoom_out,
            onTap: () => cameraController.setZoom((cameraController.zoomLevel.value - 0.5).clamp(1.0, 5.0)),
          ),
          const SizedBox(width: 8),
          StreamingIconButton(
            icon: Icons.zoom_in,
            onTap: () => cameraController.setZoom((cameraController.zoomLevel.value + 0.5).clamp(1.0, 5.0)),
          ),
          const SizedBox(width: 8),
          AutoReconnectWidget(
            isVisible: previewController.isActive.value,
            isEnabled: streamController.autoReconnectEnabled.value,
            onToggle: () => coordinator.streamController.toggleAutoReconnect(),
          ),
// Exposure
          const SizedBox(width: 8),
          ConnectionStatusBadge(
            status: streamController.connectionStatus.value,
            reconnectAttempts: streamController.reconnectAttempts.value,
            maxAttempts: 3,
          ),
          Obx(() => StreamingIconButton(
            icon: coordinator.isBreakActive.value
                ? Icons.play_arrow
                : Icons.coffee,
            iconColor: coordinator.isBreakActive.value ? Colors.green : Colors.orange,
            onTap: () => coordinator.toggleBreakScreen(),
          )),

        ],
      ),
    );
  }
}