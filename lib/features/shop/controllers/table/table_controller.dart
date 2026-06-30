import 'package:cuex_app/features/shop/controllers/table/table_model.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../data/repositories/table/table_repository.dart';
import '../../../../utils/popups/loaders.dart';

class TableController extends GetxController {
  static TableController get instance => Get.find();

  final _repo = Get.put(TableRepository());
  final isLoading = false.obs;
  final tables = <TableModel>[].obs;

  Future<void> fetchVenueTables(String venueId) async {
    try {
      isLoading.value = true;
      tables.assignAll(await _repo.fetchVenueTables(venueId));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTable(TableModel table) async {
    try {
      await _repo.addTable(table);
      await fetchVenueTables(table.venueId);
      TLoaders.successSnackBar(title: 'Success', message: 'Table added successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> updateTable(TableModel table) async {
    try {
      await _repo.updateTable(table);
      await fetchVenueTables(table.venueId);
      TLoaders.successSnackBar(title: 'Success', message: 'Table updated successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> deleteTable(String tableId, String venueId) async {
    try {
      await _repo.deleteTable(tableId);
      await fetchVenueTables(venueId);
      TLoaders.successSnackBar(title: 'Success', message: 'Table deleted successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}