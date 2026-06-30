import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../features/personalization/controllers/user_controller.dart';
import '../features/shop/controllers/event_controller.dart';
import '../features/shop/controllers/high_break.dart';
import '../features/shop/controllers/matches_controller.dart';
import '../features/shop/controllers/news_controller.dart';
import '../features/shop/controllers/promotion_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => PromotionController(), fenix: true);
    Get.lazyPut(() => MatchController(), fenix: true);
    Get.lazyPut(() => EventController(), fenix: true);
    Get.lazyPut(() => NewsController(), fenix: true);
    Get.lazyPut(() => HighestBreaksController(), fenix: true);
  }
}