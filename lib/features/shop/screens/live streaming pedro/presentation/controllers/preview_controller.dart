import 'package:get/get.dart';

import '../../../../../../data/services/streaming/streaming_service.dart';

class PreviewController extends GetxController {
  // Observable state
  final isActive = false.obs;
  final isStarting = false.obs;
  final selectedResolution = '1080p'.obs;
  final selectedWidth = 1920.obs;
  final selectedHeight = 1080.obs;
  final error = Rx<String?>(null);

  Future<void> startPreview({
    required Map<String, dynamic> matchData,
  }) async {
    try {
      isStarting.value = true;
      error.value = null;

      // Wait for surface to be ready
      await Future.delayed(const Duration(milliseconds: 1500)); // Increase delay

      final success = await StreamingService.startPreview(
        matchData,
        width: selectedWidth.value,
        height: selectedHeight.value,
        bitrate: _calculateBitrate(selectedResolution.value),
      );

      if (success) {
        await Future.delayed(const Duration(seconds: 2));
        isActive.value = true;
      }

      _logEvent('preview_started', {
        'resolution': selectedResolution.value,
        'width': selectedWidth.value,
        'height': selectedHeight.value,
      });
    } catch (e) {
      error.value = e.toString();
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> stopPreview() async {
    try {
      await StreamingService.stopPreview();
      isActive.value = false;

      _logEvent('preview_stopped');
    } catch (e) {
      error.value = e.toString();
    }
  }

  void updateQuality({
    required String resolution,
    required int width,
    required int height,
  }) {
    selectedResolution.value = resolution;
    selectedWidth.value = width;
    selectedHeight.value = height;
  }

  int _calculateBitrate(String resolution) {
    switch (resolution) {
      case '4K':
        return 13000 * 1024;
      case '1080p':
        return 5000 * 1024;
      case '720p':
        return 2500 * 1024;
      case '480p':
        return 1500 * 1024;
      default:
        return 2500 * 1024;
    }
  }

  void _logEvent(String event, [Map<String, dynamic>? data]) {
    print('Analytics: $event ${data ?? ""}');
  }
}
//
// // Usage
// final previewController = Get.put(PreviewController());
//
// // In UI
// Obx(() {
// if (previewController.isStarting.value) {
// return CircularProgressIndicator();
// }
//
// return ElevatedButton(
// onPressed: () => previewController.startPreview(matchData: {...}),
// child: Text(previewController.isActive.value ? 'Stop Preview' : 'Start Preview'),
// );
// })