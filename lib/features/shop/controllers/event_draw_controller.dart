import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/repositories/events/event_draw_repository.dart';
import '../../../data/repositories/events/event_repository.dart';
import '../../../data/repositories/events/events_participants.dart';
import '../../../data/services/notifications/notification_service.dart';
import '../../../utils/popups/loaders.dart';
import '../models/event_draw_model.dart';

class EventDrawController extends GetxController {
  static EventDrawController get instance => Get.find();

  final _repo = Get.put(EventDrawRepository());

  final isLoading = false.obs;
  final isUploading = false.obs;

  final draws = <EventDrawModel>[].obs;
  final results = <EventDrawModel>[].obs;

  // Form fields
  final titleController = TextEditingController();
  final pickedImage = Rxn<File>();
  final existingImageUrl = ''.obs;

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  /// Reset form to empty state
  void resetForm() {
    titleController.clear();
    pickedImage.value = null;
    existingImageUrl.value = '';
  }

  /// Prefill form for editing
  void prefill(EventDrawModel draw) {
    titleController.text = draw.title;
    existingImageUrl.value = draw.imageUrl;
    pickedImage.value = null;
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        pickedImage.value = File(picked.path);
        print('📋 EventDrawController — picked: ${picked.path}');
      }
    } catch (e) {
      print('🔴 EventDrawController pickImage error: $e');
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Could not pick image');
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> _uploadImage(File image, String drawId) async {
    try {
      isUploading.value = true;
      print('📋 EventDrawController — uploading image for draw: $drawId');
      final ext = image.path.split('.').last.toLowerCase();
      final ref = FirebaseStorage.instance
          .ref('event_draws/$drawId/file.$ext');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      print('📋 EventDrawController — uploaded: $url');
      return url;
    } catch (e) {
      print('🔴 EventDrawController _uploadImage error: $e');
      TLoaders.errorSnackBar(
          title: 'Upload Failed',
          message: 'Image could not be uploaded');
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  /// Get FCM token for a user
  Future<String> _getPlayerToken(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      return doc.data()?['fcmToken'] ?? '';
    } catch (e) {
      print('🔴 EventDrawController _getPlayerToken error: $e');
      return '';
    }
  }

  /// Send notification to all registered participants of the event
  Future<void> _notifyParticipants(String eventId, String type, String eventName) async {
    try {
      print('📋 EventDrawController — notifying participants for event: $eventId type: $type');
      final repo = Get.isRegistered<EventParticipantRepository>()
          ? Get.find<EventParticipantRepository>()
          : Get.put(EventParticipantRepository());

      final participants =
      await repo.fetchParticipantsByEvent(eventId);
      print('📋 EventDrawController — participants to notify: ${participants.length}');

      final tokens = <String>[];
      for (final p in participants) {
        if (p.status == 'withdrawn') continue;
        final token = await _getPlayerToken(p.userId);
        if (token.isNotEmpty) tokens.add(token);
      }

      if (tokens.isEmpty) {
        print('📋 EventDrawController — no tokens found');
        return;
      }

      await TNotificationService.instance.sendToTokens(
        tokens: tokens,
        title: type == 'draw'
            ? '$eventName — Draw Published 🎱'
            : '$eventName — Results Published 📊',
        body: type == 'draw'
            ? 'The $eventName draw has been published. Check your bracket!'
            : 'Latest results for $eventName have been published. Check now!',
        data: {
          'type': type == 'draw' ? 'draw_published' : 'result_published',
          'eventId': eventId,
        },
      );
      print('📋 EventDrawController — notifications sent to ${tokens.length} participants');
    } catch (e) {
      print('🔴 EventDrawController _notifyParticipants error (non-fatal): $e');
    }
  }

  /// Fetch draws or results by type
  Future<void> fetchDraws(String eventId, String type) async {
    try {
      isLoading.value = true;
      print('📋 EventDrawController fetchDraws — eventId: $eventId type: $type');
      final list = await _repo.fetchByEventAndType(eventId, type);
      if (type == 'draw') {
        draws.assignAll(list);
      } else {
        results.assignAll(list);
      }
      print('📋 EventDrawController fetchDraws — loaded: ${list.length}');
    } catch (e) {
      print('🔴 EventDrawController fetchDraws error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add new draw or result
  Future<void> addDraw(
      String eventId, String type, BuildContext context) async {
    try {
      if (titleController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(
            title: 'Missing', message: 'Please enter a title');
        return;
      }
      if (pickedImage.value == null) {
        TLoaders.warningSnackBar(
            title: 'Missing', message: 'Please select an image');
        return;
      }

      isLoading.value = true;
      print('📋 EventDrawController addDraw — eventId: $eventId type: $type');

      // Create Firestore doc first to get ID
      final draw = EventDrawModel(
        id: '',
        eventId: eventId,
        title: titleController.text.trim(),
        imageUrl: '',
        type: type,
        uploadedBy: FirebaseAuth.instance.currentUser?.uid ?? '',
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final drawId = await _repo.addDraw(draw);
      print('📋 EventDrawController addDraw — created doc: $drawId');

      // Upload image
      final url = await _uploadImage(pickedImage.value!, drawId);
      if (url != null) {
        await _repo.updateField(drawId, {
          'imageUrl': url,
          'updatedAt': DateTime.now(),
        });
        print('📋 EventDrawController addDraw — image url saved');
      }

      // Refresh list
      await fetchDraws(eventId, type);
      resetForm();

      // Notify participants
      final event = await EventRepository.instance.fetchSingleItem(eventId);
      await _notifyParticipants(eventId, type, event.name);
      TLoaders.successSnackBar(
        title: 'Success',
        message: type == 'draw'
            ? 'Draw uploaded successfully'
            : 'Result uploaded successfully',
      );
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      print('🔴 EventDrawController addDraw error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update existing draw or result
  Future<void> updateDraw(
      EventDrawModel draw, String eventId, BuildContext context) async {
    try {
      if (titleController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(
            title: 'Missing', message: 'Please enter a title');
        return;
      }

      isLoading.value = true;
      print('📋 EventDrawController updateDraw — id: ${draw.id}');

      draw.title = titleController.text.trim();
      draw.updatedAt = DateTime.now();

      // Upload new image if picked
      if (pickedImage.value != null) {
        final url = await _uploadImage(pickedImage.value!, draw.id);
        if (url != null) draw.imageUrl = url;
      }

      await _repo.updateDraw(draw);
      await fetchDraws(eventId, draw.type);
      resetForm();

      TLoaders.successSnackBar(
          title: 'Updated', message: 'Updated successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      print('🔴 EventDrawController updateDraw error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> pickFile() async {
    try {
      // Request both — one will work depending on Android version
      await Permission.storage.request();
      await Permission.photos.request();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.single.path != null) {
        pickedImage.value = File(result.files.single.path!);
        print('📋 picked: ${result.files.single.path}');
      }
    } catch (e) {
      print('🔴 pickFile error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: 'Could not pick file');
    }
  }
  /// Delete draw or result
  Future<void> deleteDraw(EventDrawModel draw, String eventId) async {
    try {
      print('📋 EventDrawController deleteDraw — id: ${draw.id}');
      await _repo.deleteDraw(draw.id);

      // Delete image from Firebase Storage
      if (draw.imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance
              .refFromURL(draw.imageUrl)
              .delete();
          print('📋 EventDrawController deleteDraw — image deleted');
        } catch (e) {
          print('⚠️ EventDrawController deleteDraw — image delete failed (non-fatal): $e');
        }
      }

      // Remove from local list
      if (draw.type == 'draw') {
        draws.removeWhere((d) => d.id == draw.id);
      } else {
        results.removeWhere((d) => d.id == draw.id);
      }

      TLoaders.successSnackBar(
          title: 'Deleted', message: 'Deleted successfully');
    } catch (e) {
      print('🔴 EventDrawController deleteDraw error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}