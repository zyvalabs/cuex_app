import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/match_creation_controller.dart';
import '../../../../core/widgets/image/thumbnailpicker.dart';


/// Thumbnail upload — shows the picked/uploaded image, or a loading
/// state while the upload is in progress.
class YoutubeThumbnailSection extends StatelessWidget {
  const YoutubeThumbnailSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchCreationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thumbnail', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isUploadingThumbnail.value) {
            return Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }

          return ThumbnailPickerBox(
            imagePath: controller.youtubeThumbnailUrl.value,
            onTap: () => controller.pickAndUploadThumbnail(),
          );
        }),
      ],
    );
  }
}