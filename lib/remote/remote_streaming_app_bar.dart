import 'package:cuex_app/features/shop/screens/live%20streaming%20pedro/presentation/widgets/quality_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/buttons/streaming_icon_button.dart';
import '../../../../../../utils/helpers/streaming_utils.dart';

import '../features/shop/screens/live streaming pedro/presentation/controllers/audio_controller.dart';
import '../features/shop/screens/live streaming pedro/presentation/controllers/camera_controller.dart';
import '../features/shop/screens/live streaming pedro/presentation/controllers/preview_controller.dart';
import '../features/shop/screens/live streaming pedro/presentation/controllers/remote_streaming.dart';
import '../features/shop/screens/live streaming pedro/presentation/controllers/stream_controller.dart';
import '../features/shop/screens/live streaming pedro/presentation/widgets/auto_reconnect.dart';
import '../features/shop/screens/live streaming pedro/presentation/widgets/connection_status_badge.dart';


class RemoteStreamingAppBar extends StatelessWidget {
  final String matchId;

  const RemoteStreamingAppBar({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    final coordinator = Get.find<RemoteStreamCoordinator>();
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
          StreamingIconButton(
            icon: Icons.arrow_back,
            onTap: () async {
              final shouldPop = await handleStreamingBackPress(
                context: context,
                matchId: matchId,
              );
              if (shouldPop && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 8),
          StreamingIconButton(
            icon: Icons.flip_camera_android,
            onTap: () => coordinator.switchCamera(),
          ),
          const SizedBox(width: 8),
          StreamingIconButton(
            icon: Icons.settings,
            onTap: () => showQualitySelectorDialog(context),
          ),
          const SizedBox(width: 8),
          Obx(() => StreamingIconButton(
            icon: audioController.isMuted.value ? Icons.mic_off : Icons.mic,
            iconColor: audioController.isMuted.value ? Colors.red : Colors.white,
            isEnabled: previewController.isActive.value,
            onTap: () => coordinator.toggleAudio(),
          )),
          const SizedBox(width: 8),
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
          const SizedBox(width: 8),
          ConnectionStatusBadge(
            status: streamController.connectionStatus.value,
            reconnectAttempts: streamController.reconnectAttempts.value,
            maxAttempts: 3,
          ),
        ],
      ),
    );
  }
}