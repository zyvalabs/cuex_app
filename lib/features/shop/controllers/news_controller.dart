import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/news/news_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/news_model.dart';

class NewsController extends GetxController {
  static NewsController get instance => Get.find();

  final _repo = Get.put(NewsRepository());

  final isLoading = false.obs;
  final isUploading = false.obs;
  final allNews = <NewsModel>[].obs;
  final publishedNews = <NewsModel>[].obs;

  // Form
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final videoUrlController = TextEditingController();
  final selectedCategory = 'General'.obs;
  final isPublished = false.obs;
  final pickedImage = Rxn<File>();
  final existingImageUrl = ''.obs;

  final categories = ['General', 'Tournament', 'Venue Update', 'Sport News', 'Announcement'];

  @override
  void onInit() {
    fetchPublishedNews();
    super.onInit();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();
    super.onClose();
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    videoUrlController.clear();
    selectedCategory.value = 'General';
    isPublished.value = false;
    pickedImage.value = null;
    existingImageUrl.value = '';
  }

  void prefill(NewsModel news) {
    titleController.text = news.title;
    descriptionController.text = news.description;
    videoUrlController.text = news.videoUrl ?? '';
    selectedCategory.value = news.category;
    isPublished.value = news.isPublished;
    existingImageUrl.value = news.imageUrl;
    pickedImage.value = null;
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

  Future<String?> _uploadImage(File image, String newsId) async {
    try {
      isUploading.value = true;
      final ref = FirebaseStorage.instance.ref('news/$newsId/cover.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Upload Failed', message: 'Image could not be uploaded');
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  /// Fetch published news — for players
  Future<void> fetchPublishedNews() async {
    try {
      isLoading.value = true;
      publishedNews.assignAll(await _repo.fetchPublishedNews());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all news — for admin
  Future<void> fetchAllNews() async {
    try {
      isLoading.value = true;
      allNews.assignAll(await _repo.fetchAllNews());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add news — admin only
  Future<void> addNews(BuildContext context) async {
    try {
      if (titleController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(title: 'Missing', message: 'Please enter a title');
        return;
      }
      if (descriptionController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(title: 'Missing', message: 'Please enter a description');
        return;
      }

      isLoading.value = true;

      final news = NewsModel(
        id: '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        imageUrl: '',
        videoUrl: videoUrlController.text.trim().isNotEmpty ? videoUrlController.text.trim() : null,
        category: selectedCategory.value,
        isPublished: isPublished.value,
        createdBy: UserController.instance.user.value.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final newsId = await _repo.addNews(news);

      // Upload image if picked
      if (pickedImage.value != null) {
        final url = await _uploadImage(pickedImage.value!, newsId);
        if (url != null) {
          await _repo.updateNews(NewsModel.fromJson(newsId, {...news.toJson(), 'imageUrl': url, 'id': newsId}));
        }
      }

      await fetchAllNews();
      resetForm();
      TLoaders.successSnackBar(title: 'Success', message: 'News added successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update news — admin only
  Future<void> updateNews(NewsModel news, BuildContext context) async {
    try {
      isLoading.value = true;

      news.title = titleController.text.trim();
      news.description = descriptionController.text.trim();
      news.videoUrl = videoUrlController.text.trim().isNotEmpty ? videoUrlController.text.trim() : null;
      news.category = selectedCategory.value;
      news.isPublished = isPublished.value;
      news.updatedAt = DateTime.now();

      if (pickedImage.value != null) {
        final url = await _uploadImage(pickedImage.value!, news.id);
        if (url != null) news.imageUrl = url;
      }

      await _repo.updateNews(news);
      await fetchAllNews();
      resetForm();
      TLoaders.successSnackBar(title: 'Updated', message: 'News updated successfully');
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle publish — admin only
  Future<void> togglePublish(String newsId, bool isPublished) async {
    try {
      await _repo.togglePublish(newsId, isPublished);
      final index = allNews.indexWhere((n) => n.id == newsId);
      if (index != -1) allNews[index].isPublished = isPublished;
      allNews.refresh();
      TLoaders.successSnackBar(title: 'Updated', message: isPublished ? 'News published' : 'News unpublished');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Delete news — admin only
  Future<void> deleteNews(String newsId) async {
    try {
      await _repo.deleteNews(newsId);
      allNews.removeWhere((n) => n.id == newsId);
      publishedNews.removeWhere((n) => n.id == newsId);
      TLoaders.successSnackBar(title: 'Deleted', message: 'News deleted successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}