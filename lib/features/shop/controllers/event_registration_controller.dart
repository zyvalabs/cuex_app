import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/events/event_repository.dart';
import '../../../data/repositories/events/events_participants.dart';
import '../../../data/services/notifications/notification_service.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/event_participant_model.dart';
import '../../../utils/popups/loaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/events/event_repository.dart';
import '../../../data/repositories/events/events_participants.dart';
import '../../../data/services/notifications/notification_service.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/event_participant_model.dart';
import '../../../utils/popups/loaders.dart';

class EventParticipantController extends GetxController {
  static EventParticipantController get instance => Get.find();

  final isLoading = false.obs;
  final eventParticipantRepository = Get.put(EventParticipantRepository());

  /// Current user's registration status for the viewed event
  final isRegistered = false.obs;
  final currentParticipant = Rx<EventParticipantModel?>(null);

  RxList<EventParticipantModel> participants = <EventParticipantModel>[].obs;
  RxList<EventParticipantModel> userParticipations = <EventParticipantModel>[].obs;
  RxInt participantCount = 0.obs;

  /// Register user for event
  /// Handles re-registration if previously withdrawn
  Future<void> registerForEvent({
    required String eventId,
    required String userId,
    double? entryFee,
  }) async {
    print('🎯 registerForEvent — eventId: $eventId userId: $userId');
    try {
      isLoading.value = true;

      // Check existing registration
      final existing = await eventParticipantRepository.getParticipantByEventAndUser(eventId, userId);

      if (existing != null) {
        if (existing.status == 'withdrawn') {
          // Re-register after withdrawal
          print('🎯 Re-registering withdrawn participant: ${existing.id}');
          await eventParticipantRepository.updateSingleField(existing.id, {
            'status': 'registered',
            'paymentStatus': entryFee != null && entryFee > 0 ? 'pending' : 'waived',
            'withdrawnAt': null,
            'withdrawalReason': null,
            'registeredAt': DateTime.now(),
            'updatedAt': DateTime.now(),
          });
          currentParticipant.value = await eventParticipantRepository.getParticipantByEventAndUser(eventId, userId);
          isRegistered.value = true;
          TLoaders.successSnackBar(
            title: 'Re-registered! 🎱',
            message: 'You have re-registered for this event. The venue will contact you shortly.',
          );
          fetchParticipantsByEvent(eventId);
          return;
        }
        // Already registered and active
        print('⚠️ Already registered with status: ${existing.status}');
        TLoaders.warningSnackBar(title: 'Already Registered', message: 'You are already registered for this event');
        return;
      }

      // Check slots if maxParticipants is set
      final event = await EventRepository.instance.fetchSingleItem(eventId);
      if (event.maxParticipants > 0) {
        final count = await eventParticipantRepository.countParticipants(eventId);
        final slotsLeft = event.maxParticipants - count;
        print('🎯 Slots check — max: ${event.maxParticipants} count: $count slotsLeft: $slotsLeft');
        if (slotsLeft <= 0) {
          TLoaders.errorSnackBar(title: 'Event Full', message: 'This event is full — no slots remaining');
          return;
        }
        // Notify if almost full (< 20% slots left)
        if (slotsLeft <= (event.maxParticipants * 0.2).toInt()) {
          await TNotificationService.instance.sendToTopic(
            topic: 'all_users',
            title: '🔥 Almost Full!',
            body: '${event.name} — only $slotsLeft slots left!',
            data: {'type': 'slots_running_out', 'eventId': eventId},
          );
        }
      }

      // Create new registration
      final participant = EventParticipantModel(
        id: '',
        eventId: eventId,
        userId: userId,
        status: 'registered',
        paymentStatus: entryFee != null && entryFee > 0 ? 'pending' : 'waived',
        amountPaid: entryFee,
        registeredAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await eventParticipantRepository.addItem(participant);
      print('🎯 Registration created successfully');

      // Update local state
      currentParticipant.value = await eventParticipantRepository.getParticipantByEventAndUser(eventId, userId);
      isRegistered.value = true;

      TLoaders.successSnackBar(
        title: 'Registration Successful! 🎱',
        message: 'You\'re registered! The venue will contact you shortly to confirm your spot.',
      );

      fetchParticipantsByEvent(eventId);
    } catch (e) {
      print('🔴 registerForEvent error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Check registration status — accounts for all statuses including withdrawn
  Future<void> checkRegistration(String eventId, String userId) async {
    try {
      print('🎯 checkRegistration — eventId: $eventId userId: $userId');
      final participant = await eventParticipantRepository.getParticipantByEventAndUser(eventId, userId);
      currentParticipant.value = participant;
      isRegistered.value = participant != null && participant.status != 'withdrawn';
      print('🎯 checkRegistration — status: ${participant?.status} isRegistered: ${isRegistered.value}');
    } catch (e) {
      print('🔴 checkRegistration error: $e');
      isRegistered.value = false;
      currentParticipant.value = null;
    }
  }

  /// Fetch all participants for an event
  Future<void> fetchParticipantsByEvent(String eventId) async {
    try {
      print('🎯 fetchParticipantsByEvent — eventId: $eventId');
      isLoading.value = true;
      final list = await eventParticipantRepository.fetchParticipantsByEvent(eventId);
      participants.assignAll(list);
      participantCount.value = list.length;
      print('🎯 fetchParticipantsByEvent — loaded: ${list.length}');
    } catch (e) {
      print('🔴 fetchParticipantsByEvent error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add unregistered (non-CueX) user as participant — admin/partner only
  Future<void> addUnregisteredParticipant({
    required String eventId,
    required String firstName,
    required String lastName,
    String? email,
    String? phoneNumber,
    XFile? profileImage,
    double? entryFee,
  }) async {
    print('🎯 addUnregisteredParticipant — $firstName $lastName eventId: $eventId');
    isLoading.value = true;
    try {
      final userId = await UserController.instance.addUnregisteredUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
      );

      final participant = EventParticipantModel(
        id: '',
        eventId: eventId,
        userId: userId,
        status: 'registered',
        paymentStatus: entryFee != null && entryFee > 0 ? 'pending' : 'waived',
        amountPaid: entryFee,
        registeredAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await eventParticipantRepository.addItem(participant);
      print('🎯 addUnregisteredParticipant — created successfully');
      fetchParticipantsByEvent(eventId);
    } catch (e) {
      print('🔴 addUnregisteredParticipant error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all events a user has participated in
  Future<void> fetchUserParticipations(String userId) async {
    try {
      print('🎯 fetchUserParticipations — userId: $userId');
      isLoading.value = true;
      final list = await eventParticipantRepository.fetchParticipantsByUser(userId);
      userParticipations.assignAll(list);
      print('🎯 fetchUserParticipations — loaded: ${list.length}');
    } catch (e) {
      print('🔴 fetchUserParticipations error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update participant registration status — sends notification on confirm
  Future<void> updateParticipantStatus(String participantId, String status) async {
    print('🎯 updateParticipantStatus — id: $participantId status: $status');
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now(),
      };

      if (status == 'confirmed') {
        updates['confirmedAt'] = DateTime.now();
        // Send push notification to player
        final doc = await eventParticipantRepository.fetchSingleItem(participantId);
        final token = await _getPlayerToken(doc.userId);
        if (token.isNotEmpty) {
          await TNotificationService.instance.sendToTokens(
            tokens: [token],
            title: 'Registration Confirmed ✅',
            body: 'Your event registration has been confirmed. See you at the event!',
            data: {'type': 'registration_confirmed', 'participantId': participantId},
          );
          print('🎯 Confirmation notification sent to: ${doc.userId}');
        }
      }

      await eventParticipantRepository.updateSingleField(participantId, updates);
      print('🎯 updateParticipantStatus — updated successfully');
      TLoaders.successSnackBar(title: 'Updated', message: 'Participant status updated to $status');
    } catch (e) {
      print('🔴 updateParticipantStatus error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Update payment status — admin/partner only
  Future<void> updatePaymentStatus({
    required String participantId,
    required String paymentStatus,
    double? amountPaid,
    String? paymentMethod,
    String? transactionId,
  }) async {
    print('🎯 updatePaymentStatus — id: $participantId status: $paymentStatus amount: $amountPaid');
    try {
      final updates = <String, dynamic>{
        'paymentStatus': paymentStatus,
        'updatedAt': DateTime.now(),
      };
      if (amountPaid != null) updates['amountPaid'] = amountPaid;
      if (paymentMethod != null) updates['paymentMethod'] = paymentMethod;
      if (transactionId != null) updates['transactionId'] = transactionId;

      await eventParticipantRepository.updateSingleField(participantId, updates);
      print('🎯 updatePaymentStatus — updated successfully');
      TLoaders.successSnackBar(title: 'Payment Updated', message: 'Payment status updated to $paymentStatus');
    } catch (e) {
      print('🔴 updatePaymentStatus error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Withdraw participant from event — sends notification to player
  Future<void> withdrawFromEvent(String participantId, String reason) async {
    print('🎯 withdrawFromEvent — id: $participantId reason: $reason');
    try {
      await eventParticipantRepository.updateSingleField(participantId, {
        'status': 'withdrawn',
        'withdrawnAt': DateTime.now(),
        'withdrawalReason': reason,
        'updatedAt': DateTime.now(),
      });

      // Send push notification to player
      final doc = await eventParticipantRepository.fetchSingleItem(participantId);
      final token = await _getPlayerToken(doc.userId);
      if (token.isNotEmpty) {
        await TNotificationService.instance.sendToTokens(
          tokens: [token],
          title: 'Registration Withdrawn ❌',
          body: 'Your event registration has been withdrawn. Reason: $reason',
          data: {'type': 'registration_withdrawn', 'participantId': participantId},
        );
        print('🎯 Withdrawal notification sent to: ${doc.userId}');
      }

      print('🎯 withdrawFromEvent — withdrawn successfully');
      TLoaders.successSnackBar(title: 'Withdrawn', message: 'Participant has been withdrawn from the event');
    } catch (e) {
      print('🔴 withdrawFromEvent error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Check if user is registered (simple bool check)
  Future<bool> checkUserRegistration(String eventId, String userId) async {
    try {
      return await eventParticipantRepository.isUserRegistered(eventId, userId);
    } catch (e) {
      print('🔴 checkUserRegistration error: $e');
      return false;
    }
  }

  /// Get participant count for event
  Future<void> getParticipantCount(String eventId) async {
    try {
      print('🎯 getParticipantCount — eventId: $eventId');
      final count = await eventParticipantRepository.countParticipants(eventId);
      participantCount.value = count;
      print('🎯 getParticipantCount — count: $count');
    } catch (e) {
      print('🔴 getParticipantCount error: $e');
    }
  }

  /// Internal — get FCM token for a user
  Future<String> _getPlayerToken(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      return doc.data()?['fcmToken'] ?? '';
    } catch (e) {
      print('🔴 _getPlayerToken error: $e');
      return '';
    }
  }
}