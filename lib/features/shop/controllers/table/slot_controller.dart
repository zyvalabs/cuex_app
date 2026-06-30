import 'package:cuex_app/features/shop/controllers/table/slot_mdoel.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../data/repositories/table/slot_repository.dart';
import '../../../../utils/popups/loaders.dart';

class SlotController extends GetxController {
  static SlotController get instance => Get.find();

  final _repo = Get.put(SlotRepository());
  final isLoading = false.obs;
  final slots = <SlotModel>[].obs;
  final selectedSlot = SlotModel.empty().obs;

  Future<void> fetchTableSlots(String tableId, DateTime date) async {
    try {
      isLoading.value = true;
      slots.assignAll(await _repo.fetchTableSlots(tableId, date));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVenueSlots(String venueId, DateTime date) async {
    try {
      isLoading.value = true;
      slots.assignAll(await _repo.fetchVenueSlots(venueId, date));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void selectSlot(SlotModel slot) => selectedSlot.value = slot;

  Future<void> updateSlotStatus(String slotId, String status) async {
    try {
      await _repo.updateSlotStatus(slotId, status);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}