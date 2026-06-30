import 'package:get/get.dart';

import '../../../../../../data/services/streaming/streaming_service.dart';

class CameraController extends GetxController {
  // Observable state
  final zoomLevel = 1.0.obs;
  final isSwitching = false.obs;
  final isAutoFocusEnabled = false.obs;
  final error = Rx<String?>(null);
  final exposureOffset = 0.obs;  // not 0.0.obs
  Future<void> setZoom(double zoom) async {
    try {
      final success = await StreamingService.setZoom(zoom);
      if (success) {
        zoomLevel.value = zoom;
        // Log analytics
        logEvent('camera_zoom_changed', {'zoom_level': zoom});
      }
    } catch (e) {
      error.value = e.toString();
    }
  }
  Future<void> setExposure(int offset) async {
    try {
      final success = await StreamingService.setExposure(offset);
      if (success) exposureOffset.value = offset;
    } catch (e) {
      error.value = e.toString();
    }
  }
  Future<void> switchCamera() async {
    try {
      isSwitching.value = true;
      error.value = null;

      final success = await StreamingService.switchCamera();

      if (success) {
        zoomLevel.value = 1.0;
        logEvent('camera_switched');
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isSwitching.value = false;
    }
  }

  // Future<void> toggleAutoFocus() async {
  //   try {
  //     final newState = !isAutoFocusEnabled.value;
  //
  //     final success = await StreamingService.toggleAutoFocus(newState);
  //
  //     if (success) {
  //       isAutoFocusEnabled.value = newState;
  //       logEvent('auto_focus_toggled', {'enabled': newState});
  //     }
  //   } catch (e) {
  //     error.value = e.toString();
  //   }
  // }

  void logEvent(String event, [Map<String, dynamic>? data]) {
    // Add your analytics logging here
    print('Analytics: $event ${data ?? ""}');
  }
}
