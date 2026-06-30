import 'package:cuex_app/features/shop/screens/news/widget/category_selector.dart';
import 'package:cuex_app/features/shop/screens/news/widget/image_picker.dart';
import 'package:cuex_app/features/shop/screens/news/widget/news_toggle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../controllers/news_controller.dart';
import '../../models/news_model.dart';

class AddEditNewsScreen extends StatefulWidget {
  const AddEditNewsScreen({super.key, this.news});
  final NewsModel? news;

  @override
  State<AddEditNewsScreen> createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  late final NewsController controller;

  bool get isEdit => widget.news != null;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<NewsController>()
        ? Get.find<NewsController>()
        : Get.put(NewsController());
    if (isEdit) controller.prefill(widget.news!);
  }

  @override
  void dispose() {
    if (!isEdit) controller.resetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit News' : 'Add News')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            const NewsImagePicker(),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Title
            TextFormField(
              controller: controller.titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Iconsax.document_text, size: 18),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Description
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 6,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description *',
                prefixIcon: Icon(Iconsax.document, size: 18),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Video URL
            TextFormField(
              controller: controller.videoUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'YouTube Video URL (Optional)',
                prefixIcon: Icon(Iconsax.video_play, size: 18),
                hintText: 'https://youtube.com/watch?v=...',
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Category
            const NewsCategorySelector(),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Publish toggle
            const NewsPublishToggle(),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Submit
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => isEdit
                    ? controller.updateNews(widget.news!, context)
                    : controller.addNews(context),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: controller.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEdit ? 'Update News' : 'Publish News'),
              ),
            )),
            const SizedBox(height: TSizes.defaultSpace),
          ],
        ),
      ),
    );
  }
}