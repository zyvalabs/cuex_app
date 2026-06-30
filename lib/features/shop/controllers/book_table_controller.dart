
import 'package:cuex_app/features/shop/controllers/slot_controller.dart';
import 'package:cuex_app/features/shop/controllers/table/table_controller.dart';
import 'package:cuex_app/features/shop/controllers/venue_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class BookTableController extends GetxController {
  static BookTableController get instance => Get.find();

  final selected = DateTime.now().obs;
  final selectedSportId = ''.obs;
  void selectSport(String id) => selectedSportId.value = id;
  final selectedTableId = ''.obs;
  final selectedSlotIds = <String>[].obs;
  void selectSlot(String startTime) {
    if (selectedSlotIds.contains(startTime)) {
      selectedSlotIds.remove(startTime);
    } else {
      selectedSlotIds.add(startTime);
    }
  }


  void updateMonth(int index) {
    selected.value =
        DateTime(selected.value.year, index + 1, selected.value.day);
  }
  void selectTable(String id) {
    selectedTableId.value = id;
    final table = TableController.instance.tables.firstWhere((t) => t.id == id);
    SlotController.instance.generateSlots(
      table: table,
      venue: VenueController.instance.venue.value,
      date: selected.value,
    );
  }
  void updateDay(int index) {
    selected.value =
        DateTime(selected.value.year, selected.value.month, index + 1);
  }
}