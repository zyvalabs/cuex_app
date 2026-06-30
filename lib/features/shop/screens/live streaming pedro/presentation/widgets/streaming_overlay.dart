
import 'package:cuex_app/features/shop/screens/live%20streaming%20pedro/presentation/widgets/stream_health_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../controllers/preview_controller.dart';
import '../controllers/stream_controller.dart';
import '../controllers/streaming_coordinator.dart';
import '../controllers/streaming_overlay_controller.dart';

class StreamingOverlay extends StatelessWidget {
  final String matchId;
  final String matchName;
  final RxBool isCameraSurfaceReady;

  const StreamingOverlay({
    super.key,
    required this.matchId,
    required this.matchName,
    required this.isCameraSurfaceReady,
  });

  @override
  Widget build(BuildContext context) {
    final coordinator = Get.find<StreamingCoordinator>(tag: matchId);
    final streamController = Get.find<LiveStreamController>();

    final overlayController = Get.put(
      StreamingOverlayController(coordinator: coordinator, matchName: matchName),
      tag: matchId,
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(

        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (streamController.isStreaming.value && streamController.streamHealth.value != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StreamHealthIndicator(health: streamController.streamHealth.value!),
              ),

            // Padding(
            //   padding: const EdgeInsets.only(bottom: 54),
            //   child: ConnectionStatusBadge(
            //     status: streamController.connectionStatus.value,
            //     reconnectAttempts: streamController.reconnectAttempts.value,
            //     maxAttempts: 3,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: StreamActionButton(
                overlayController: overlayController,
                isCameraSurfaceReady: isCameraSurfaceReady,
              ),
            ),


          ],
        )),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UI — StreamActionButton
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StreamActionButton extends StatelessWidget {
  final StreamingOverlayController overlayController;
  final RxBool isCameraSurfaceReady;

  const StreamActionButton({
    super.key,
    required this.overlayController,
    required this.isCameraSurfaceReady,
  });

  @override
  Widget build(BuildContext context) {
    final previewController = Get.find<PreviewController>();
    final streamController = Get.find<LiveStreamController>();

    return Obx(() {
      final isLoading = streamController.isStarting.value ||
          streamController.isStopping.value ||
          previewController.isStarting.value;

      if (!previewController.isActive.value) {
        return SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: isCameraSurfaceReady.value && !isLoading
                ? () => overlayController.handleStartPreview(context)
                : null,
            icon: isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.videocam, size: 18),
            label: Text(isCameraSurfaceReady.value ? 'Preview' : 'Init...'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
      }

      if (streamController.isStreaming.value) {
        return SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => overlayController.handleStopStream(context),
            icon: isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.stop_circle, size: 18),
            label: const Text('Stop Stream'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
      }

      return SizedBox(
        width: 250,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : () => overlayController.handleGoLive(context),
          icon: isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.play_circle_filled, size: 18),
          label: const Text('Go Live'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    });
  }
}