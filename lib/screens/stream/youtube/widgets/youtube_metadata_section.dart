import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/match_creation_controller.dart';


/// Title + description fields — full UI inline, pre-filled from
/// controller.autoFillYoutubeMetadata() and kept in sync as user edits.
class YoutubeMetadataSection extends StatefulWidget {
  const YoutubeMetadataSection({super.key});

  @override
  State<YoutubeMetadataSection> createState() => _YoutubeMetadataSectionState();
}

class _YoutubeMetadataSectionState extends State<YoutubeMetadataSection> {
  final controller = Get.find<MatchCreationController>();
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: controller.youtubeTitle.value);
    descriptionController = TextEditingController(text: controller.youtubeDescription.value);

    titleController.addListener(() => controller.youtubeTitle.value = titleController.text);
    descriptionController.addListener(() => controller.youtubeDescription.value = descriptionController.text);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // keep fields in sync if auto-fill happens after this widget already built
      if (titleController.text != controller.youtubeTitle.value) {
        titleController.text = controller.youtubeTitle.value;
      }
      if (descriptionController.text != controller.youtubeDescription.value) {
        descriptionController.text = controller.youtubeDescription.value;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stream Title', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'e.g. Snooker 900 — Final',
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add a description for your stream',
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );
    });
  }
}