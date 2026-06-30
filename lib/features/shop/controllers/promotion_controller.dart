import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../data/repositories/promotion/promotiion_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/promotion_model.dart';

class PromotionController extends GetxController {
  static PromotionController get instance => Get.find();

  final _repo = Get.put(PromotionRepository());
  final _storage = GetStorage();

  // Observables
  final isLoading = false.obs;
  final isUploading = false.obs;
  final activePromos = <PromotionModel>[].obs;
  final allPromos = <PromotionModel>[].obs;

  // Form fields
  final titleController = TextEditingController();
  final buttonTitleController = TextEditingController();
  final videoUrlController = TextEditingController();
  final selectedType = 'image'.obs;
  final selectedLinkType = 'internal'.obs;
  final selectedLinkRoute = '/events'.obs;
  final externalUrlController = TextEditingController();
  final isActive = true.obs;
  final order = 0.obs;
  final pickedImage = Rxn<File>();
  final existingImageUrl = ''.obs;

  // Internal route destinations
  static const List<Map<String, String>> destinations = [
    {'label': 'Events', 'route': '/events'},

    {'label': 'Live Promotion', 'route': '/live-promotion'},
    {'label': 'Leaderboard', 'route': '/leaderboard'},
    {'label': 'News', 'route': '/news'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadCachedPromos();
    fetchActivePromos();
  }

  @override
  void onClose() {
    titleController.dispose();
    buttonTitleController.dispose();
    videoUrlController.dispose();
    externalUrlController.dispose();
    super.onClose();
  }

  // ── Form ─────────────────────────────────────────────────

  void resetForm() {
    titleController.clear();
    buttonTitleController.text = 'Explore Now';
    videoUrlController.clear();
    externalUrlController.clear();
    selectedType.value = 'image';
    selectedLinkType.value = 'internal';
    selectedLinkRoute.value = '/events';
    isActive.value = true;
    order.value = 0;
    pickedImage.value = null;
    existingImageUrl.value = '';
  }

  void prefill(PromotionModel promo) {
    titleController.text = promo.title;
    buttonTitleController.text = promo.buttonTitle;
    videoUrlController.text = promo.videoUrl;
    selectedType.value = promo.type;
    selectedLinkType.value = promo.linkType;
    selectedLinkRoute.value = promo.linkRoute;
    if (promo.linkType == 'external') {
      externalUrlController.text = promo.linkRoute;
    }
    isActive.value = promo.isActive;
    order.value = promo.order;
    existingImageUrl.value = promo.imageUrl;
    pickedImage.value = null;
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
        selectedType.value = 'image';
        print('🎯 PromotionController — picked: ${picked.path}');
      }
    } catch (e) {
      print('🔴 PromotionController pickImage error: $e');
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Could not pick image');
    }
  }

  // ── Validation ────────────────────────────────────────────

  bool _validate() {
    if (titleController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Missing', message: 'Please enter a title');
      return false;
    }
    if (buttonTitleController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Missing', message: 'Please enter a button title');
      return false;
    }
    if (selectedType.value == 'image' && pickedImage.value == null && existingImageUrl.value.isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Missing', message: 'Please select an image');
      return false;
    }
    if (selectedType.value == 'video' && videoUrlController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Missing', message: 'Please enter a video URL');
      return false;
    }
    if (selectedLinkType.value == 'external' && externalUrlController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Missing', message: 'Please enter an external URL');
      return false;
    }
    return true;
  }

  // ── Storage Upload ────────────────────────────────────────

  Future<String?> _uploadImage(File image, String promoId) async {
    try {
      isUploading.value = true;
      print('🎯 PromotionController — uploading image for promo: $promoId');
      final ext = image.path.split('.').last.toLowerCase();
      final ref = FirebaseStorage.instance
          .ref('promotions/$promoId/image.$ext');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      print('🎯 PromotionController — uploaded: $url');
      return url;
    } catch (e) {
      print('🔴 PromotionController _uploadImage error: $e');
      TLoaders.errorSnackBar(
          title: 'Upload Failed',
          message: 'Image could not be uploaded');
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  // ── Fetch ─────────────────────────────────────────────────

  Future<void> fetchActivePromos() async {
    try {
      isLoading.value = true;
      print('🎯 PromotionController fetchActivePromos');
      final list = await _repo.fetchActivePromos();
      activePromos.assignAll(list);
      _cachePromos(list);
      print('🎯 PromotionController fetchActivePromos — loaded: ${list.length}');
    } catch (e) {
      print('🔴 PromotionController fetchActivePromos error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllPromos() async {
    try {
      isLoading.value = true;
      print('🎯 PromotionController fetchAllPromos');
      final list = await _repo.fetchAllPromos();
      allPromos.assignAll(list);
      print('🎯 PromotionController fetchAllPromos — loaded: ${list.length}');
    } catch (e) {
      print('🔴 PromotionController fetchAllPromos error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── CRUD ──────────────────────────────────────────────────

  Future<void> addPromo(BuildContext context) async {
    if (!_validate()) return;

    try {
      isLoading.value = true;
      print('🎯 PromotionController addPromo');

      final linkRoute = selectedLinkType.value == 'internal'
          ? selectedLinkRoute.value
          : externalUrlController.text.trim();

      final promo = PromotionModel(
        id: '',
        title: titleController.text.trim(),
        buttonTitle: buttonTitleController.text.trim(),
        imageUrl: '',
        videoUrl: videoUrlController.text.trim(),
        linkType: selectedLinkType.value,
        linkRoute: linkRoute,
        type: selectedType.value,
        isActive: isActive.value,
        order: order.value,
        viewCount: 0,
        createdBy: FirebaseAuth.instance.currentUser?.uid ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final promoId = await _repo.addPromo(promo);
      print('🎯 PromotionController addPromo — created: $promoId');

      if (selectedType.value == 'image' && pickedImage.value != null) {
        final url = await _uploadImage(pickedImage.value!, promoId);
        if (url != null) {
          await _repo.updateField(promoId, {
            'imageUrl': url,
            'updatedAt': DateTime.now(),
          });
        }
      }

      await fetchAllPromos();
      await fetchActivePromos();
      resetForm();

      TLoaders.successSnackBar(
          title: 'Success', message: 'Promotion added successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      print('🔴 PromotionController addPromo error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePromo(
      PromotionModel promo, BuildContext context) async {
    if (!_validate()) return;

    try {
      isLoading.value = true;
      print('🎯 PromotionController updatePromo — id: ${promo.id}');

      promo.title = titleController.text.trim();
      promo.buttonTitle = buttonTitleController.text.trim();
      promo.videoUrl = videoUrlController.text.trim();
      promo.type = selectedType.value;
      promo.linkType = selectedLinkType.value;
      promo.linkRoute = selectedLinkType.value == 'internal'
          ? selectedLinkRoute.value
          : externalUrlController.text.trim();
      promo.isActive = isActive.value;
      promo.order = order.value;
      promo.updatedAt = DateTime.now();

      if (pickedImage.value != null) {
        final url = await _uploadImage(pickedImage.value!, promo.id);
        if (url != null) promo.imageUrl = url;
      }

      await _repo.updatePromo(promo);
      await fetchAllPromos();
      await fetchActivePromos();
      resetForm();

      TLoaders.successSnackBar(
          title: 'Updated', message: 'Promotion updated successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      print('🔴 PromotionController updatePromo error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePromo(PromotionModel promo) async {
    try {
      print('🎯 PromotionController deletePromo — id: ${promo.id}');
      await _repo.deletePromo(promo.id);

      if (promo.imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance
              .refFromURL(promo.imageUrl)
              .delete();
        } catch (e) {
          print('⚠️ image delete failed (non-fatal): $e');
        }
      }

      allPromos.removeWhere((p) => p.id == promo.id);
      activePromos.removeWhere((p) => p.id == promo.id);

      TLoaders.successSnackBar(
          title: 'Deleted', message: 'Promotion deleted successfully');
    } catch (e) {
      print('🔴 PromotionController deletePromo error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> toggleActive(PromotionModel promo) async {
    try {
      print('🎯 PromotionController toggleActive — id: ${promo.id}');
      await _repo.toggleActive(promo.id, !promo.isActive);
      promo.isActive = !promo.isActive;
      allPromos.refresh();
      await fetchActivePromos();
    } catch (e) {
      print('🔴 PromotionController toggleActive error: $e');
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> updateOrder(String id, int newOrder) async {
    try {
      await _repo.updateOrder(id, newOrder);
      await fetchAllPromos();
    } catch (e) {
      print('🔴 PromotionController updateOrder error: $e');
    }
  }

  Future<void> incrementViewCount(String id) async {
    await _repo.incrementViewCount(id);
  }

  Future<void> openLink(PromotionModel promo) async {
    try {
      if (promo.linkType == 'internal') {
        Get.toNamed(promo.linkRoute);
      } else {
        final uri = Uri.parse(promo.linkRoute);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('🔴 PromotionController openLink error: $e');
    }
  }

  // ── Cache ─────────────────────────────────────────────────

  void _cachePromos(List<PromotionModel> promos) {
    try {
      _storage.write(
          'activePromos', promos.map((p) => p.toJson()).toList());
    } catch (e) {
      print('⚠️ PromotionController _cachePromos error: $e');
    }
  }

  void _loadCachedPromos() {
    try {
      final data = _storage.read('activePromos');
      if (data != null) {
        final list = (data as List)
            .map((e) => PromotionModel.fromJson(
            e['id'] ?? '', Map<String, dynamic>.from(e)))
            .toList();
        activePromos.assignAll(list);
        print('🎯 PromotionController — loaded ${list.length} from cache');
      }
    } catch (e) {
      print('⚠️ PromotionController _loadCachedPromos error: $e');
    }
  }
}