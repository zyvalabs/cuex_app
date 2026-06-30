import 'package:cuex_app/features/shop/controllers/table/table_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/table/table_repository.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/venue_controller.dart';
import '../../models/sport_model.dart';

class AddTableController extends GetxController {
  static AddTableController get instance => Get.find();

  final addTableFormKey = GlobalKey<FormState>();
  final tableName = TextEditingController();
  final brand = TextEditingController();
  final maxPlayers = TextEditingController();

  final selectedSportIds = <String>[].obs;
  final selectedTableType = Rxn<TableType>();
  final availableTableTypes = <TableType>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    print('🎮 AddTableController onInit');
    final venueController = VenueController.instance;

    ever(venueController.venue, (venue) {
      print('🏢 Venue changed: ${venue.id} — sportIds: ${venue.sportIds}');
      if (venue.id.isNotEmpty) venueController.fetchVenueSports(venue.sportIds);
    });

    if (venueController.venue.value.id.isNotEmpty) {
      venueController.fetchVenueSports(venueController.venue.value.sportIds);
    } else {
      venueController.fetchPartnerVenue(UserController.instance.user.value.id);
    }

    super.onInit();
  }

  void onSportSelected(SportModel sport) {
    if (selectedSportIds.contains(sport.id)) {
      selectedSportIds.remove(sport.id);
    } else {
      selectedSportIds.add(sport.id);
    }
    _updateAvailableTableTypes();
  }

  void _updateAvailableTableTypes() {
    final venueController = VenueController.instance;
    final selectedSports = venueController.venueSports.where((s) => selectedSportIds.contains(s.id)).toList();

    final types = <TableType>{};
    for (final sport in selectedSports) {
      final name = sport.name.toLowerCase();
      if (name.contains('snooker')) {
        types.addAll([TableType.english, TableType.french]);
      } else if (name.contains('pool')) {
        types.add(TableType.american);
      } else if (name.contains('billiard')) {
        types.add(TableType.billiard);
      } else {
        types.addAll(TableType.values);
      }
    }

    availableTableTypes.assignAll(types.toList());
    if (!availableTableTypes.contains(selectedTableType.value)) {
      selectedTableType.value = null;
    }
  }

  void onTableTypeSelected(TableType type) => selectedTableType.value = type;

  Future<void> saveTable(String venueId, BuildContext context) async {
    try {
      if (!addTableFormKey.currentState!.validate()) return;

      if (selectedSportIds.isEmpty) {
        TLoaders.warningSnackBar(title: 'Select Sport', message: 'Please select at least one sport');
        return;
      }

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.customToast(message: 'No Internet Connection');
        return;
      }

      isLoading.value = true;

      final resolvedVenueId = venueId.isNotEmpty ? venueId : VenueController.instance.venue.value.id;
      final table = TableModel(
        id: '',
        venueId: resolvedVenueId,
        sportIds: selectedSportIds.toList(),
        tableName: tableName.text.trim(),
        tableType: selectedTableType.value,
        brand: brand.text.trim().isNotEmpty ? brand.text.trim() : null,
        maxPlayers: int.tryParse(maxPlayers.text.trim()),
      );

      await Get.put(TableRepository()).addTable(table);

      isLoading.value = false;
      TLoaders.successSnackBar(title: 'Success', message: '${table.tableName} added successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      isLoading.value = false;
      print('🔴 AddTable Error: $e');
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  @override
  void onClose() {
    tableName.dispose();
    brand.dispose();
    maxPlayers.dispose();
    super.onClose();
  }
}