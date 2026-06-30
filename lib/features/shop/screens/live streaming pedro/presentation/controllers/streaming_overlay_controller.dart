import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../../common/widgets/dialog/confirmation_dialog.dart';
import '../controllers/preview_controller.dart';
import '../controllers/streaming_coordinator.dart';
import '../widgets/streaming_error_dialog.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONTROLLER — business logic only
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class StreamingOverlayController extends GetxController {
  final StreamingCoordinator coordinator;
  final String matchName;

  StreamingOverlayController({
    required this.coordinator,
    required this.matchName,
  });

  Future<void> handleStartPreview(BuildContext context) async {
    try {
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          if (!context.mounted) return;
          if (cameraStatus.isPermanentlyDenied) {
            _showPermissionSettingsDialog(context, 'Camera');
          } else {
            showStreamingErrorDialog(context, 'Camera permission is required for streaming');
          }
          return;
        }
      }

      var micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
        if (!micStatus.isGranted) {
          if (!context.mounted) return;
          if (micStatus.isPermanentlyDenied) {
            _showPermissionSettingsDialog(context, 'Microphone');
          } else {
            showStreamingErrorDialog(context, 'Microphone permission is required for streaming');
          }
          return;
        }
      }

      await coordinator.startPreview();
    } catch (e) {
      if (context.mounted) {
        showStreamingErrorDialog(context, 'Failed to start preview: ${e.toString()}');
      }
    }
  }

  Future<void> handleGoLive(BuildContext context) async {
    final previewController = Get.find<PreviewController>();
    if (!previewController.isActive.value) {
      showStreamingErrorDialog(context, 'Please wait for preview to start first');
      return;
    }
    try {
      await coordinator.goLive(matchName: matchName);
    } catch (e) {
      if (context.mounted) showStreamingErrorDialog(context, e.toString());
    }
  }

  Future<void> handleStopStream(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'End Stream?',
      message: 'Are you sure you want to end the live stream?',
      confirmText: 'End Stream',
      cancelText: 'Cancel',
      isDangerous: true,
    );
    if (confirmed == true) {
      try {
        await coordinator.stopStream();
      } catch (e) {
        if (context.mounted) showStreamingErrorDialog(context, e.toString());
      }
    }
  }

  void _showPermissionSettingsDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(
          '$permission permission is permanently denied. Please enable it in app settings to use live streaming.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UI — StreamingOverlay
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
