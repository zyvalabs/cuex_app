import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../features/shop/controllers/venue_controller.dart';

class VenueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VenueController());
  }
}