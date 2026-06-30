import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/venue/venue_repository.dart';

import '../../../data/services/images/image_upload_service.dart';
import '../../../utils/popups/loaders.dart';
import '../models/sport_model.dart';
import '../models/venue_model.dart';

class AddEditVenueController extends GetxController {
  static AddEditVenueController get instance => Get.find();

  final _repo = Get.put(VenueRepository());

  // Step
  final step = 0.obs;
  final totalSteps = 6  ;
  final isLoading = false.obs;
  final isUploading = false.obs;

  // Step 1 - Venue Info
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();

  // Step 2 - Location
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;

  // Step 3 - Timings
  final openTime = '09:00'.obs;
  final closeTime = '23:00'.obs;

  // Step 4 - Sports
  final selectedSportIds = <String>[].obs;

  // Step 5 - Amenities & Images
  final selectedAmenities = <String>[].obs;
  final pickedThumbnail = Rxn<File>();
  final pickedGalleryImages = <File>[].obs;
  final thumbnailImage = ''.obs;
  final galleryImages = <String>[].obs;

  // Step 6 - Social Links
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final youtubeController = TextEditingController();

  final stepLabels = ['Venue Info', 'Location', 'Timings', 'Sports', 'Images', 'Amenities'];

  void nextStep() { if (step.value < totalSteps - 1) step.value++; }
  void prevStep() { if (step.value > 0) step.value--; }

  void onSportSelected(SportModel sport) {
    if (selectedSportIds.contains(sport.id)) {
      selectedSportIds.remove(sport.id);
    } else {
      selectedSportIds.add(sport.id);
    }
  }

  void onAmenitySelected(String amenity) {
    if (selectedAmenities.contains(amenity)) {
      selectedAmenities.remove(amenity);
    } else {
      selectedAmenities.add(amenity);
    }
  }

  /// Pick thumbnail image
  Future<void> pickThumbnail(BuildContext context) async {
    print('🖼️ pickThumbnail called — hashCode: $hashCode');
    final file = await ImageUploadService.instance.pickImage();
    print('🖼️ File: $file');
    if (file != null) {
      pickedThumbnail.value = file;
      print('🖼️ Set pickedThumbnail: ${pickedThumbnail.value?.path}');
    }
  }
  /// Pick gallery images
  Future<void> pickGalleryImages() async {
    final files = await ImageUploadService.instance.pickMultipleImages();
    if (files.isNotEmpty) pickedGalleryImages.addAll(files);
  }

  /// Remove gallery image by index
  void removeGalleryImage(int index) {
    if (index < pickedGalleryImages.length) {
      pickedGalleryImages.removeAt(index);
    } else {
      galleryImages.removeAt(index - pickedGalleryImages.length);
    }
  }

  void prefill(VenueModel venue) {
    nameController.text = venue.name;
    descriptionController.text = venue.description;
    phoneController.text = venue.phone ?? '';
    websiteController.text = venue.website ?? '';
    addressController.text = venue.address;
    cityController.text = venue.city;
    stateController.text = '';
    countryController.text = '';
    latitude.value = venue.location.latitude;
    longitude.value = venue.location.longitude;
    openTime.value = venue.openTime;
    closeTime.value = venue.closeTime;
    selectedSportIds.assignAll(venue.sportIds);
    selectedAmenities.assignAll(venue.amenities);
    thumbnailImage.value = venue.thumbnailImage;
    galleryImages.assignAll(venue.images);
    pickedThumbnail.value = null;
    pickedGalleryImages.clear();
    instagramController.text = venue.socialLinks?['instagram'] ?? '';
    facebookController.text = venue.socialLinks?['facebook'] ?? '';
    youtubeController.text = venue.socialLinks?['youtube'] ?? '';
  }

  /// Save venue — handles both add and edit
  Future<void> saveVenue(BuildContext context, {VenueModel? existingVenue}) async {
    print('🏢 saveVenue called — name: ${nameController.text} city: ${cityController.text}');
    print('🏢 isEdit: ${existingVenue != null}');
    print('🏢 lat: ${latitude.value} lng: ${longitude.value}');
    try {
      if (nameController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(title: 'Missing', message: 'Please enter venue name');
        return;
      }
      if (cityController.text.trim().isEmpty) {
        TLoaders.warningSnackBar(title: 'Missing', message: 'Please enter city');
        return;
      }

      isLoading.value = true;

      String thumbnailUrl = thumbnailImage.value;
      List<String> galleryUrls = galleryImages.toList();

      final isEdit = existingVenue != null;
      final venueId = isEdit ? existingVenue.id : FirebaseFirestore.instance.collection('Venues').doc().id;

      // Upload thumbnail if picked
      if (pickedThumbnail.value != null) {
        isUploading.value = true;
        final url = await ImageUploadService.instance.uploadImage(
          pickedThumbnail.value!,
          'venues/$venueId/thumbnail.jpg',
        );
        if (url != null) thumbnailUrl = url;
        isUploading.value = false;
      }

      // Upload gallery images if picked
      if (pickedGalleryImages.isNotEmpty) {
        isUploading.value = true;
        final urls = await ImageUploadService.instance.uploadMultipleImages(
          pickedGalleryImages.toList(),
          'venues/$venueId/gallery',
        );
        galleryUrls.addAll(urls);
        isUploading.value = false;
      }

      final venue = VenueModel(
        id: venueId,
        partnerId: existingVenue?.partnerId ?? '',
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        city: cityController.text.trim(),
        address: addressController.text.trim(),
        location: GeoPoint(latitude.value, longitude.value),
        thumbnailImage: thumbnailUrl,
        images: galleryUrls,
        amenities: selectedAmenities.toList(),
        sportIds: selectedSportIds.toList(),
        openTime: openTime.value,
        closeTime: closeTime.value,
        status: existingVenue?.status ?? 'closed',
        isFeatured: existingVenue?.isFeatured ?? false,
        isActive: existingVenue?.isActive ?? true,
        streamingEnabled: existingVenue?.streamingEnabled ?? false,
        isTesting: existingVenue?.isTesting ?? false,
        rating: existingVenue?.rating ?? 0.0,
        totalRatings: existingVenue?.totalRatings ?? 0,
        tablesCount: existingVenue?.tablesCount ?? 0,
        createdAt: existingVenue?.createdAt ?? DateTime.now(),
        phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
        website: websiteController.text.trim().isNotEmpty ? websiteController.text.trim() : null,
        socialLinks: {
          if (instagramController.text.trim().isNotEmpty) 'instagram': instagramController.text.trim(),
          if (facebookController.text.trim().isNotEmpty) 'facebook': facebookController.text.trim(),
          if (youtubeController.text.trim().isNotEmpty) 'youtube': youtubeController.text.trim(),
        },
      );

      if (isEdit) {
        await _repo.updateVenue(venue);
        TLoaders.successSnackBar(title: 'Updated', message: '${venue.name} updated successfully');
      } else {
        await FirebaseFirestore.instance.collection('Venues').doc(venueId).set(venue.toJson());
        TLoaders.successSnackBar(title: 'Success', message: '${venue.name} added successfully');
      }

      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    youtubeController.dispose();
    super.onClose();
  }
}