import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';


import '../../../data/repositories/sports/sports_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/sport_model.dart';

class SportController extends GetxController {
  static SportController get instance => Get.find();

  final _repo = Get.put(SportRepository());
  final _storage = GetStorage();

  // Observables
  final isLoading = false.obs;
  final isUploading = false.obs;
  final allSports = <SportModel>[].obs;
  final activeSports = <SportModel>[].obs;
  final featuredSports = <SportModel>[].obs;

  // Form fields
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final iconUrlController = TextEditingController();
  final isActive = true.obs;
  final isFeatured = false.obs;
  final isTesting = false.obs;
  final order = 0.obs;
  final pickedImage = Rxn<File>();
  final existingIconUrl = ''.obs;
  final useUrlInstead = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCached();
    fetchActiveSports();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    iconUrlController.dispose();
    super.onClose();
  }

  // ── Form ─────────────────────────────────────────────────

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    iconUrlController.clear();
    isActive.value = true;
    isFeatured.value = false;
    isTesting.value = false;
    order.value = 0;
    pickedImage.value = null;
    existingIconUrl.value = '';
    useUrlInstead.value = false;
  }

  void prefill(SportModel sport) {
    nameController.text = sport.name;
    descriptionController.text = sport.description ?? '';
    iconUrlController.text = sport.iconUrl;
    isActive.value = sport.isActive;
    isFeatured.value = sport.isFeatured;
    isTesting.value = sport.isTesting;
    order.value = sport.order;
    existingIconUrl.value = sport.iconUrl;
    pickedImage.value = null;
    useUrlInstead.value = sport.iconUrl.startsWith('http') &&
        !sport.iconUrl.contains('firebasestorage');
  }

  // ── Image Picker ──────────────────────────────────────────

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        pickedImage.value = File(picked.path);
        useUrlInstead.value = false;
        iconUrlController.clear();
        print('🎱 SportController — picked: ${picked.path}');
      }
    } catch (e) {
      print('🔴 SportController pickImage error: $e');
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Could not pick image');
    }
  }

  // ── Storage Upload ────────────────────────────────────────

  Future<String?> _uploadIcon(File image, String sportId) async {
    try {
      isUploading.value = true;
      print('🎱 SportController — uploading icon for sport: $sportId');
      final ext = image.path.split('.').last.toLowerCase();
      final ref = FirebaseStorage.instance
          .ref('sports/$sportId/icon.$ext');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      print('🎱 SportController — uploaded: $url');
      return url;
    } catch (e) {
      print('🔴 SportController _uploadIcon error: $e');
      TLoaders.errorSnackBar(
          title: 'Upload Failed',
          message: 'Icon could not be uploaded');
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  // ── Validation ────────────────────────────────────────────

  bool _validate() {
    if (nameController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Missing', message: 'Please enter sport name');
      return false;
    }
    return true;
  }

  // ── Fetch ─────────────────────────────────────────────────

  Future<void> fetchAllSports() async {
    try {
      isLoading.value = true;
      print('🎱 SportController fetchAllSports');
      final list = await _repo.fetchAllSports();
      allSports.assignAll(list);
      print('🎱 SportController fetchAllSports — loaded: ${list.length}');
    } catch (e) {
      print('🔴 SportController fetchAllSports error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActiveSports() async {
    try {
      isLoading.value = true;
      print('🎱 SportController fetchActiveSports');
      final list = await _repo.fetchActiveSports();
      activeSports.assignAll(list);
      _cacheActiveSports(list);
      print('🎱 SportController fetchActiveSports — loaded: ${list.length}');
    } catch (e) {
      print('🔴 SportController fetchActiveSports error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFeaturedSports() async {
    try {
      print('🎱 SportController fetchFeaturedSports');
      final list = await _repo.fetchFeaturedSports();
      featuredSports.assignAll(list);
      print('🎱 SportController fetchFeaturedSports — loaded: ${list.length}');
    } catch (e) {
      print('🔴 SportController fetchFeaturedSports error: $e');
    }
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> addSport(BuildContext context) async {
    if (!_validate()) return;
    try {
      isLoading.value = true;
      print('🎱 SportController addSport — name: ${nameController.text}');

      final sport = SportModel(
        id: '',
        name: nameController.text.trim(),
        iconUrl: useUrlInstead.value ? iconUrlController.text.trim() : '',
        isActive: isActive.value,
        isFeatured: isFeatured.value,
        isTesting: isTesting.value,
        order: order.value,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final sportId = await _repo.addSport(sport);
      print('🎱 SportController addSport — created: $sportId');

      // Upload image if picked
      if (pickedImage.value != null && !useUrlInstead.value) {
        final url = await _uploadIcon(pickedImage.value!, sportId);
        if (url != null) {
          await _repo.updateField(sportId, {
            'iconUrl': url,
            'updatedAt': DateTime.now(),
          });
        }
      }

      await fetchAllSports();
      await fetchActiveSports();
      resetForm();

      TLoaders.successSnackBar(
          title: 'Success', message: 'Sport added successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      print('🔴 SportController addSport error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSport(SportModel sport, BuildContext context) async {
    if (!_validate()) return;
    try {
      isLoading.value = true;
      print('🎱 SportController updateSport — id: ${sport.id}');

      sport.name = nameController.text.trim();
      sport.description = descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim();
      sport.isActive = isActive.value;
      sport.isFeatured = isFeatured.value;
      sport.isTesting = isTesting.value;
      sport.order = order.value;
      sport.updatedAt = DateTime.now();

      // Use URL if entered
      if (useUrlInstead.value && iconUrlController.text.trim().isNotEmpty) {
        sport.iconUrl = iconUrlController.text.trim();
      }

      // Upload new image if picked
      if (pickedImage.value != null && !useUrlInstead.value) {
        final url = await _uploadIcon(pickedImage.value!, sport.id);
        if (url != null) sport.iconUrl = url;
      }

      await _repo.updateSport(sport);
      await fetchAllSports();
      await fetchActiveSports();
      resetForm();

      TLoaders.successSnackBar(
          title: 'Updated', message: 'Sport updated successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      print('🔴 SportController updateSport error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSport(SportModel sport) async {
    try {
      print('🎱 SportController deleteSport — id: ${sport.id}');
      await _repo.deleteSport(sport.id);

      // Delete icon from storage
      if (sport.iconUrl.isNotEmpty &&
          sport.iconUrl.contains('firebasestorage')) {
        try {
          await FirebaseStorage.instance
              .refFromURL(sport.iconUrl)
              .delete();
        } catch (e) {
          print('⚠️ icon delete failed (non-fatal): $e');
        }
      }

      allSports.removeWhere((s) => s.id == sport.id);
      activeSports.removeWhere((s) => s.id == sport.id);
      featuredSports.removeWhere((s) => s.id == sport.id);

      TLoaders.successSnackBar(
          title: 'Deleted', message: 'Sport deleted successfully');
    } catch (e) {
      print('🔴 SportController deleteSport error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> toggleActive(SportModel sport) async {
    try {
      await _repo.toggleActive(sport.id, !sport.isActive);
      sport.isActive = !sport.isActive;
      allSports.refresh();
      await fetchActiveSports();
    } catch (e) {
      print('🔴 SportController toggleActive error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> toggleFeatured(SportModel sport) async {
    try {
      await _repo.toggleFeatured(sport.id, !sport.isFeatured);
      sport.isFeatured = !sport.isFeatured;
      allSports.refresh();
    } catch (e) {
      print('🔴 SportController toggleFeatured error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> toggleTesting(SportModel sport) async {
    try {
      await _repo.toggleTesting(sport.id, !sport.isTesting);
      sport.isTesting = !sport.isTesting;
      allSports.refresh();
    } catch (e) {
      print('🔴 SportController toggleTesting error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> updateOrder(String id, int newOrder) async {
    try {
      await _repo.updateOrder(id, newOrder);
      await fetchAllSports();
    } catch (e) {
      print('🔴 SportController updateOrder error: $e');
    }
  }

  // ── Cache ─────────────────────────────────────────────────

  void _cacheActiveSports(List<SportModel> sports) {
    try {
      final data = sports.map((s) {
        final json = Map<String, dynamic>.from(s.toJson());
        json.removeWhere((k, v) => v is Timestamp || v is DateTime);
        json['id'] = s.id;
        return json;
      }).toList();
      _storage.write('activeSports', data);
    } catch (e) {
      print('⚠️ SportController _cacheActiveSports error: $e');
    }
  }
  void _loadCached() {
    try {
      final data = _storage.read('activeSports');
      if (data != null) {
        final list = (data as List)
            .map((e) => SportModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        activeSports.assignAll(list);
        print('🎱 SportController — loaded ${list.length} from cache');
      }
    } catch (e) {
      print('⚠️ SportController _loadCached error: $e');
    }
  }
}