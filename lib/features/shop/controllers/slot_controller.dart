import 'package:cuex_app/features/shop/controllers/table/slot_mdoel.dart';
import 'package:cuex_app/features/shop/controllers/table/table_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


import '../../../data/repositories/slot/slot_repository.dart';
import '../../../data/services/slots/slot_generator_service.dart';
import '../../../utils/popups/loaders.dart';
import '../models/venue_model.dart';
// Updated SlotController
class SlotController extends GetxController {
  static SlotController get instance => Get.find();

  final _repo = Get.put(SlotRepository());
  final isLoading = false.obs;
  final slots = <SlotModel>[].obs;
  final selectedSlots = <String>[].obs;

  Future<void> generateSlots({required TableModel table, required VenueModel venue, required DateTime date}) async {
    final generated = SlotGeneratorService.generateSlots(
      venueId: venue.id,
      tableId: table.id,
      openTime: venue.openTime,
      closeTime: venue.closeTime,
      date: date,
    );

    // Fetch existing slots from Firestore
    final existing = await _repo.fetchTableSlots(table.id, date);
    print('📋 Existing from Firestore: ${existing.map((s) => '${s.startTime}:${s.price}:${s.discountedPrice}').toList()}');

    // Merge — if slot exists in Firestore use it, else use generated
    final merged = generated.map((slot) {
      final found = existing.cast<SlotModel?>().firstWhere((e) => e?.startTime == slot.startTime, orElse: () => null);
      return found ?? slot;
    }).toList();

    slots.assignAll(merged);
    selectedSlots.clear();
  }

  void toggleSlot(String startTime) {
    if (selectedSlots.contains(startTime)) {
      selectedSlots.remove(startTime);
    } else {
      selectedSlots.add(startTime);
    }
  }

  void selectAll() => selectedSlots.assignAll(slots.map((s) => s.startTime).toList());
  void clearSelection() => selectedSlots.clear();

  void setPricingForSelected(double price, double discountedPrice) {
    for (final startTime in selectedSlots) {
      updateSlotPrice(startTime, price, discountedPrice);
    }
  }

  void updateSlotPrice(String startTime, double price, double discountedPrice) {
    final index = slots.indexWhere((s) => s.startTime == startTime);
    if (index != -1) {
      final s = slots[index];
      slots[index] = SlotModel(
        id: s.id,
        tableId: s.tableId,
        venueId: s.venueId,
        date: s.date,
        startTime: s.startTime,
        endTime: s.endTime,
        status: s.status,
        price: price,
        discountedPrice: discountedPrice,
        pricingTiers: s.pricingTiers,
        createdAt: s.createdAt,
      );
      slots.refresh(); // ← this was missing
    }
  }

  Future<void> saveSlots(BuildContext context) async {
    try {
      final toSave = slots.where((s) => s.price > 0).toList();
      if (toSave.isEmpty) {
        TLoaders.warningSnackBar(title: 'No Pricing Set', message: 'Please set pricing for at least one slot');
        return;
      }

      isLoading.value = true;

      for (final slot in toSave) {
        if (slot.id.isNotEmpty) {
          await _repo.updateSlotPricing(slot.id, slot.price, slot.discountedPrice);
        } else {
          await _repo.addSlot(slot);
        }
      }

      isLoading.value = false;
      TLoaders.successSnackBar(title: 'Success', message: '${toSave.length} slots saved');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}