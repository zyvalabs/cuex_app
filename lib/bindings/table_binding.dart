import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../data/repositories/table/table_repository.dart';
import '../features/shop/controllers/table/add_table_controller.dart';
import '../features/shop/controllers/table/table_controller.dart';

class TablesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TableRepository());
    Get.lazyPut(() => TableController());
    Get.lazyPut(() => AddTableController());
  }
}