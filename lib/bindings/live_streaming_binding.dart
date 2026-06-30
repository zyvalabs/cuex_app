import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../features/shop/controllers/match_stat_controller.dart';

class LiveStreamingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatchStatsController());
    // add any other controllers needed for streaming
  }
}