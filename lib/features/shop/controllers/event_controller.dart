import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../data/repositories/events/event_repository.dart';
import '../../../data/services/notifications/notification_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/event_model.dart';

class EventController extends GetxController {
  static EventController get instance => Get.find();

  final isLoading = false.obs;
  final isUploading = false.obs;
  RxList<EventModel> allEvents = <EventModel>[].obs;
  RxList<EventModel> upcomingEvents = <EventModel>[].obs;
  RxList<EventModel> featuredEvents = <EventModel>[].obs;
  final eventRepository = Get.put(EventRepository());

  // --- Form ---
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final maxParticipantsController = TextEditingController();
  final entryFeeController = TextEditingController();
  final prizePoolController = TextEditingController();
  final selectedStartDate = Rxn<DateTime>();
  final selectedEndDate = Rxn<DateTime>();
  final selectedRegistrationDeadline = Rxn<DateTime>();
  final selectedFormat = RxString('Knockout');
  final selectedParticipantType = RxString('Singles');
  final selectedVenueId = RxString('');
  final selectedVenueName = RxString('');
  final pickedImage = Rxn<File>();
  final existingImageUrl = RxString('');
  final isFeatured = false.obs;
  final isVerified = false.obs;
  final isPublic = true.obs;
  final isTesting = false.obs;
  final selectedSportId = RxString('');
  final prizes = <Map<String, dynamic>>[].obs;

  final formatOptions = ['Knockout', 'Round Robin', 'Double Elimination', 'League'];
  final participantTypeOptions = ['Singles', 'Doubles', 'Team'];

  @override
  void onInit() {
    fetchEvents();
    fetchFeaturedEvents();
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    maxParticipantsController.dispose();
    entryFeeController.dispose();
    prizePoolController.dispose();
    super.onClose();
  }

  void resetForm() {
    formKey.currentState?.reset();
    nameController.clear();
    descriptionController.clear();
    maxParticipantsController.clear();
    entryFeeController.clear();
    prizePoolController.clear();
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedRegistrationDeadline.value = null;
    selectedFormat.value = formatOptions.first;
    selectedParticipantType.value = participantTypeOptions.first;
    selectedVenueId.value = '';
    selectedVenueName.value = '';
    pickedImage.value = null;
    existingImageUrl.value = '';
    isFeatured.value = false;
    isVerified.value = false;
    isPublic.value = true;
    isTesting.value = false;
    selectedSportId.value = '';
    prizes.clear();
  }

  void prefill(EventModel e) {
    nameController.text = e.name;
    descriptionController.text = e.description ?? '';
    maxParticipantsController.text = e.maxParticipants.toString();
    entryFeeController.text = e.entryFee?.toString() ?? '';
    prizePoolController.text = e.prizePool?.toString() ?? '';
    selectedStartDate.value = e.startDate;
    selectedEndDate.value = e.endDate;
    selectedRegistrationDeadline.value = e.registrationDeadline;
    selectedFormat.value = e.format;
    selectedParticipantType.value = e.participantType;
    isFeatured.value = e.isFeatured;
    isVerified.value = e.isVerified;
    isPublic.value = e.isPublic;
    isTesting.value = e.isTesting;
    existingImageUrl.value = e.imageUrl;
    pickedImage.value = null;
    selectedSportId.value = e.sportId ?? '';
    prizes.assignAll(e.prizes);
  }

  void addPrize(String rank, double? amount) {
    prizes.add({'rank': rank, 'amount': amount ?? 0});
  }

  void removePrize(int index) => prizes.removeAt(index);

  void updatePrize(int index, String rank, double? amount) {
    prizes[index] = {'rank': rank, 'amount': amount ?? 0};
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) pickedImage.value = File(picked.path);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Could not pick image');
    }
  }

  Future<String?> _uploadImage(File image, String eventId) async {
    try {
      isUploading.value = true;
      final ref = FirebaseStorage.instance.ref('events/$eventId/cover.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Upload Failed', message: 'Image could not be uploaded');
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  Future<String?> uploadImagePublic(File image, String eventId) => _uploadImage(image, eventId);

  Future<void> pickStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null) selectedStartDate.value = date;
  }

  Future<void> pickEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedStartDate.value ?? DateTime.now(),
      firstDate: selectedStartDate.value ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null) selectedEndDate.value = date;
  }

  Future<void> pickRegistrationDeadline(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: selectedStartDate.value ?? DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null) selectedRegistrationDeadline.value = date;
  }

  bool _validate() {
    if (!formKey.currentState!.validate()) return false;
    if (selectedStartDate.value == null) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please select a start date');
      return false;
    }
    if (selectedEndDate.value == null) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please select an end date');
      return false;
    }
    if (selectedRegistrationDeadline.value == null) {
      TLoaders.warningSnackBar(title: 'Missing', message: 'Please select registration deadline');
      return false;
    }
    return true;
  }

  Future<void> submitEvent(String venueId, BuildContext context) async {
    if (!_validate()) return;
    try {
      isLoading.value = true;

      final tempEvent = EventModel(
        id: '',
        name: nameController.text.trim(),
        venueId: venueId,
        startDate: selectedStartDate.value!,
        endDate: selectedEndDate.value!,
        registrationDeadline: selectedRegistrationDeadline.value!,
        maxParticipants: int.tryParse(maxParticipantsController.text.trim()) ?? 0,
        eventStatus: EventStatus.upcoming,
        format: selectedFormat.value,
        participantType: selectedParticipantType.value,
        description: descriptionController.text.trim(),
        isFeatured: isFeatured.value,
        isVerified: isVerified.value,
        isPublic: isPublic.value,
        isTesting: isTesting.value,
        entryFee: double.tryParse(entryFeeController.text.trim()),
        prizePool: double.tryParse(prizePoolController.text.trim()),
        prizes: prizes.toList(),
        imageUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sportId: selectedSportId.value.isNotEmpty ? selectedSportId.value : null,
      );

      final eventId = await eventRepository.addItem(tempEvent);

      if (pickedImage.value != null) {
        final url = await _uploadImage(pickedImage.value!, eventId);
        if (url != null && url.isNotEmpty) {
          await eventRepository.updateSingleField(eventId, {'imageUrl': url});
        }
      }

      await TNotificationService.instance.sendToTopic(
        topic: 'all_users',
        title: 'New Event 🎱',
        body: '${nameController.text.trim()} is now open for registration!',
        data: {'type': 'event_created', 'eventId': eventId},
      );

      await fetchEvents();
      resetForm();
      TLoaders.successSnackBar(title: 'Success', message: 'Event created successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent(EventModel event, BuildContext context) async {
    try {
      isLoading.value = true;

      if (pickedImage.value != null) {
        final url = await _uploadImage(pickedImage.value!, event.id);
        if (url != null && url.isNotEmpty) {
          event.imageUrl = url;
          await eventRepository.updateSingleField(event.id, {'imageUrl': url});
        }
      }

      event.entryFee = double.tryParse(entryFeeController.text.trim());
      event.prizePool = double.tryParse(prizePoolController.text.trim());
      event.isVerified = isVerified.value;
      event.isPublic = isPublic.value;
      event.isTesting = isTesting.value;
      event.isFeatured = isFeatured.value;
      event.prizes = prizes.toList();
      event.sportId = selectedSportId.value.isNotEmpty ? selectedSportId.value : null;
      event.updatedAt = DateTime.now();

      await eventRepository.updateItem(event);
      await fetchEvents();
      TLoaders.successSnackBar(title: 'Updated', message: 'Event updated successfully');
      resetForm();
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEvent(EventModel event) async {
    try {
      isLoading.value = true;
      await eventRepository.deleteItem(event);
      try {
        await FirebaseStorage.instance.ref('events/${event.id}/cover.jpg').delete();
      } catch (_) {}
      allEvents.remove(event);
      TLoaders.successSnackBar(title: 'Deleted', message: 'Event deleted successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      final events = await eventRepository.fetchAllItems();
      allEvents.assignAll(events);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUpcomingEvents() async {
    try {
      isLoading.value = true;
      final events = await eventRepository.fetchUpcomingEvents();
      upcomingEvents.assignAll(events);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFeaturedEvents() async {
    try {
      isLoading.value = true;
      final events = await eventRepository.fetchFeaturedEvents();
      featuredEvents.assignAll(events);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEventsByStatus(String status) async {
    try {
      isLoading.value = true;
      final events = await eventRepository.fetchEventsByStatus(status);
      allEvents.assignAll(events);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEventsByVenue(String venueId) async {
    try {
      isLoading.value = true;
      final events = await eventRepository.fetchEventsByVenue(venueId);
      allEvents.assignAll(events);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEventsBySport(String sportId) async {
    try {
      isLoading.value = true;
      final events = await eventRepository.fetchEventsBySport(sportId);
      allEvents.assignAll(events);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEventsByDateRange(DateTime start, DateTime end) async {
    try {
      isLoading.value = true;
      final events = await eventRepository.fetchEventsByDateRange(start, end);
      allEvents.assignAll(events);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchEventsByName(String query) async {
    try {
      isLoading.value = true;
      final events = await eventRepository.searchEventsByName(query);
      allEvents.assignAll(events);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeEvent(String eventId, String winnerId) async {
    try {
      await eventRepository.updateSingleField(eventId, {
        'eventStatus': 'completed',
        'winnerId': winnerId,
        'completedAt': DateTime.now(),
      });

      final winner = await UserController.instance.getUserById(winnerId);
      await TNotificationService.instance.sendToTopic(
        topic: 'tournament_$eventId',
        title: 'Tournament Winner 🏆',
        body: '${winner.firstName} wins the tournament!',
        data: {'type': 'tournament_winner', 'eventId': eventId},
      );

      TLoaders.successSnackBar(title: 'Success', message: 'Event completed');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}