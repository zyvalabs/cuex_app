import 'package:get/get.dart';

import '../features/shop/controllers/completed_matches_controller.dart';

class CompletedMatchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompletedMatchesController>(
          () => CompletedMatchesController(),
    );
  }
}