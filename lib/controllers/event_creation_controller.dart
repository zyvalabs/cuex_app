import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/model/sports_model.dart';
import '../core/model/event_model.dart';
import '../repositories/event_repository.dart';

/// Controller for the "Add Event" creation flow — separate from
/// MatchCreationController since events and matches are different concerns.
class EventCreationController extends GetxController {
  final EventRepository _eventRepository = EventRepository();

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // ---------------- Step 1: Sport ----------------
  final Rx<SportsModel> selectedSport = kSports.first.obs;

  void selectSport(SportsModel sport) => selectedSport.value = sport;
  bool isSelected(SportsModel sport) => selectedSport.value.name == sport.name;

  // ---------------- Step 2: Event name + format ----------------
  final TextEditingController eventNameController = TextEditingController();

  final RxInt bestOfFrames = 3.obs; // reused as race-to-points for Billiards
  final RxnString selectedFormatValue = RxnString(); // reds count / 8-ball-9-ball

  bool get needsFormatSelector {
    final sportName = selectedSport.value.name;
    return sportName == 'Snooker' || sportName == 'Pool';
  }

  bool get showsFramesStepper => selectedSport.value.name != 'Billiards';

  final RxInt _eventNameTrigger = 0.obs;
  void onEventNameChanged() => _eventNameTrigger.value++;

  bool get isEventSetupValid {
    _eventNameTrigger.value; // register reactivity
    if (eventNameController.text.trim().isEmpty) return false;
    if (needsFormatSelector && selectedFormatValue.value == null) return false;
    return true;
  }

  // ---------------- Save ----------------
  final RxBool isSaving = false.obs;
  final RxnString saveError = RxnString();

  Future<String?> createEvent() async {
    isSaving.value = true;
    saveError.value = null;

    // ignore: avoid_print
    print('🔵 [EventCreationController] createEvent() started');

    try {
      final sportName = selectedSport.value.name;
      final isBilliards = sportName == 'Billiards';

      final event = EventModel(
        eventName: eventNameController.text.trim(),
        sport: sportName,
        format: needsFormatSelector ? (selectedFormatValue.value ?? '') : '',
        raceToPoints: isBilliards ? bestOfFrames.value : null,
        createdBy: _userId,
        createdAt: DateTime.now(),
      );

      // ignore: avoid_print
      print('🔵 [EventCreationController] writing: ${event.toJson()}');

      final eventId = await _eventRepository.createEvent(event);

      // ignore: avoid_print
      print('🟢 [EventCreationController] Event created — id=$eventId');

      isSaving.value = false;
      return eventId;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [EventCreationController] createEvent() FAILED: $e');

      saveError.value = e.toString();
      isSaving.value = false;
      return null;
    }
  }

  @override
  void onClose() {
    eventNameController.dispose();
    super.onClose();
  }
}