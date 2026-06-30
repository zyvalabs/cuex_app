import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../features/shop/screens/live streaming pedro/presentation/controllers/audio_controller.dart';
import '../features/shop/screens/live streaming pedro/presentation/controllers/broadcast_controller.dart';
import '../features/shop/screens/live streaming pedro/presentation/controllers/camera_controller.dart';
import '../features/shop/screens/live streaming pedro/presentation/controllers/preview_controller.dart';
import '../features/shop/screens/live streaming pedro/presentation/controllers/stream_controller.dart';

class StreamingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PreviewController());
    Get.lazyPut(() => LiveStreamController());
    Get.lazyPut(() => AudioController());
    Get.lazyPut(() => CameraController());
    Get.lazyPut(() => BroadcastController());
    // Don't put StreamingCoordinator here - it's per-match
  }
}