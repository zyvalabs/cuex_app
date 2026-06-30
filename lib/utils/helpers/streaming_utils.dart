// lib/common/utils/streaming_utils.dart
import 'package:flutter/material.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';


import '../../features/shop/screens/live streaming pedro/presentation/controllers/stream_controller.dart';
import '../../features/shop/screens/live streaming pedro/presentation/controllers/streaming_coordinator.dart';
Future<bool> handleStreamingBackPress({
  required BuildContext context,
  required String matchId,
}) async {
  final streamController = Get.find<LiveStreamController>();

  if (!streamController.isStreaming.value) return true;

  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text(
        'Exit Live Stream?',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'You are currently live. Exiting will stop the stream.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
          ),
          child: const Text('Exit & Stop'),
        ),
      ],
    ),
  );

  if (shouldExit == true && context.mounted) {
    final coordinator = Get.find<StreamingCoordinator>(tag: matchId);
    await coordinator.stopStream();
  }

  return shouldExit == true;
}