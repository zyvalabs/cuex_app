import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {

  static final ImageUploadService instance =
  ImageUploadService._();

  ImageUploadService._();

  final ImagePicker _picker = ImagePicker();

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  // PICK SINGLE IMAGE
  Future<File?> pickImage({
    int quality = 80,
  }) async {

    try {

      debugPrint('🖼️ OPENING GALLERY');

      final XFile? picked =
      await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );

      debugPrint(
        '🖼️ PICKED FILE: ${picked?.path}',
      );

      if (picked == null) {

        debugPrint(
          '🖼️ USER CANCELLED IMAGE PICKER',
        );

        return null;
      }

      final file = File(picked.path);

      debugPrint(
        '🖼️ FILE EXISTS: ${file.existsSync()}',
      );

      return file;

    } catch (e) {

      debugPrint(
        '🖼️ pickImage ERROR: $e',
      );

      return null;
    }
  }

  // PICK MULTIPLE IMAGES
  Future<List<File>> pickMultipleImages({
    int quality = 80,
  }) async {

    try {

      debugPrint(
        '🖼️ OPENING MULTI IMAGE PICKER',
      );

      final List<XFile> picked =
      await _picker.pickMultiImage(
        imageQuality: quality,
      );

      debugPrint(
        '🖼️ TOTAL PICKED: ${picked.length}',
      );

      return picked
          .map((e) => File(e.path))
          .toList();

    } catch (e) {

      debugPrint(
        '🖼️ pickMultipleImages ERROR: $e',
      );

      return [];
    }
  }

  // PICK FROM CAMERA
  Future<File?> pickFromCamera({
    int quality = 80,
  }) async {

    try {

      debugPrint('🖼️ OPENING CAMERA');

      final XFile? picked =
      await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality,
      );

      debugPrint(
        '🖼️ CAMERA FILE: ${picked?.path}',
      );

      if (picked == null) {

        debugPrint(
          '🖼️ USER CANCELLED CAMERA',
        );

        return null;
      }

      return File(picked.path);

    } catch (e) {

      debugPrint(
        '🖼️ pickFromCamera ERROR: $e',
      );

      return null;
    }
  }

  // UPLOAD SINGLE IMAGE
  Future<String?> uploadImage(
      File image,
      String path,
      ) async {

    try {

      debugPrint(
        '🖼️ UPLOADING TO: $path',
      );

      final ref = _storage.ref(path);

      final uploadTask =
      await ref.putFile(image);

      debugPrint(
        '🖼️ UPLOAD STATE: ${uploadTask.state}',
      );

      final url =
      await ref.getDownloadURL();

      debugPrint(
        '🖼️ DOWNLOAD URL: $url',
      );

      return url;

    } catch (e) {

      debugPrint(
        '🖼️ uploadImage ERROR: $e',
      );

      return null;
    }
  }

  // UPLOAD MULTIPLE IMAGES
  Future<List<String>> uploadMultipleImages(
      List<File> images,
      String basePath,
      ) async {

    final List<String> urls = [];

    try {

      for (int i = 0; i < images.length; i++) {

        debugPrint(
          '🖼️ UPLOADING IMAGE INDEX: $i',
        );

        final url = await uploadImage(
          images[i],
          '$basePath/image_$i.jpg',
        );

        if (url != null) {
          urls.add(url);
        }
      }

      return urls;

    } catch (e) {

      debugPrint(
        '🖼️ uploadMultipleImages ERROR: $e',
      );

      return [];
    }
  }

  // DELETE IMAGE
  Future<void> deleteImage(
      String url,
      ) async {

    try {

      debugPrint(
        '🖼️ DELETING IMAGE: $url',
      );

      final ref =
      _storage.refFromURL(url);

      await ref.delete();

      debugPrint(
        '🖼️ IMAGE DELETED',
      );

    } catch (e) {

      debugPrint(
        '🖼️ deleteImage ERROR: $e',
      );
    }
  }

  // SHOW PICKER DIALOG
  Future<File?> showPickerDialog(
      BuildContext context,
      ) async {

    final completer =
    Completer<File?>();

    showModalBottomSheet(
      context: context,

      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (_) {

        return SafeArea(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [

              // GALLERY
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                ),

                title: const Text(
                  'Choose from Gallery',
                ),

                onTap: () async {

                  Navigator.pop(context);

                  await Future.delayed(
                    const Duration(
                      milliseconds: 300,
                    ),
                  );

                  final file =
                  await pickImage();

                  debugPrint(
                    '🖼️ GALLERY RESULT: $file',
                  );

                  if (!completer
                      .isCompleted) {

                    completer.complete(
                      file,
                    );
                  }
                },
              ),

              // CAMERA
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                ),

                title: const Text(
                  'Take a Photo',
                ),

                onTap: () async {

                  Navigator.pop(context);

                  await Future.delayed(
                    const Duration(
                      milliseconds: 300,
                    ),
                  );

                  final file =
                  await pickFromCamera();

                  debugPrint(
                    '🖼️ CAMERA RESULT: $file',
                  );

                  if (!completer
                      .isCompleted) {

                    completer.complete(
                      file,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {

      if (!completer.isCompleted) {

        completer.complete(null);
      }
    });

    return completer.future;
  }
}