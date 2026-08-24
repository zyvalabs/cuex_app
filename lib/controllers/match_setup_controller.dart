import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/model/sports_model.dart';

/// Holds everything from Step 1 (Choose Sport) and Step 2 (Match Setup) —
/// sport, match type, format, players, team names, and event/round linkage.
class MatchSetupController extends GetxController {
  // ---------------- Step 1: Sport ----------------
  final Rx<SportsModel> selectedSport = kSports.first.obs;

  void selectSport(SportsModel sport) => selectedSport.value = sport;
  bool isSelected(SportsModel sport) => selectedSport.value.name == sport.name;

  // ---------------- Step 2: Match type, format, players ----------------
  final RxnString selectedMatchType = RxnString('Singles');
  final RxInt bestOfFrames = 3.obs; // also reused as race-to-points for Billiards
  final RxnString selectedFormatValue = RxnString();
  final RxString mode = 'Practice'.obs;

  final List<TextEditingController> playerControllers = List.generate(4, (_) => TextEditingController());
  final TextEditingController teamNameAController = TextEditingController();
  final TextEditingController teamNameBController = TextEditingController();

  final RxInt _playerFieldTrigger = 0.obs;
  void onPlayerFieldChanged() => _playerFieldTrigger.value++;

  int get playerFieldCount {
    switch (selectedMatchType.value) {
      case 'Doubles':
        return 4;
      case 'Singles':
        return 2;
      case 'Solo':
        return 1;
      default:
        return 0;
    }
  }

  bool get needsFormatSelector {
    final sportName = selectedSport.value.name;
    return sportName == 'Snooker' || sportName == 'Pool';
  }

  bool get showsFramesStepper => selectedSport.value.name != 'Billiards';

  bool get isMatchSetupValid {
    _playerFieldTrigger.value; // register reactivity
    if (selectedMatchType.value == null) return false;
    if (needsFormatSelector && selectedFormatValue.value == null) return false;
    if (playerFieldCount == 0) return false;
    for (int i = 0; i < playerFieldCount; i++) {
      if (playerControllers[i].text.trim().isEmpty) return false;
    }
    return true;
  }

  // ---------------- Event linkage (null for standalone practice matches) ----------------
  final RxnString eventId = RxnString();
  final TextEditingController roundNameController = TextEditingController();

  /// Called from EventDetailsScreen's "Add Match" — locks sport (inherited
  /// from event) and tags this match with the event's id.
  void presetFromEvent({required String eventIdValue, required SportsModel sport}) {
    eventId.value = eventIdValue;
    selectedSport.value = sport;
  }

  bool get isLinkedToEvent => eventId.value != null;

  @override
  void onClose() {
    for (final c in playerControllers) {
      c.dispose();
    }
    teamNameAController.dispose();
    teamNameBController.dispose();
    roundNameController.dispose();
    super.onClose();
  }
}