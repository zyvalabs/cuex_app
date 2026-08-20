import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/model/event_model.dart';
import '../repositories/event_repository.dart';

/// Controller for the Events list screen — fetches the current user's
/// created events, newest first. Separate from EventCreationController
/// since browsing/listing is a different concern from creating.
class EventsListController extends GetxController {
  final EventRepository _eventRepository = EventRepository();

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    error.value = null;

    // ignore: avoid_print
    print('🟠 [EventsListController] fetchEvents() started for userId=$_userId');

    try {
      final result = await _eventRepository.getUserEvents(_userId);

      // ignore: avoid_print
      print('🟢 [EventsListController] fetched ${result.length} events');

      events.value = result;
      isLoading.value = false;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 [EventsListController] fetchEvents() FAILED: $e');

      error.value = e.toString();
      isLoading.value = false;
    }
  }
}