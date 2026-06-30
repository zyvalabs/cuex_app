import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/event_draw_controller.dart';
import '../../../models/event_draw_model.dart';

class AddDrawBottomSheet extends StatelessWidget {
  const AddDrawBottomSheet({
    super.key,
    required this.eventId,
    required this.type,
    this.existingDraw,
  });

  final String eventId;
  final String type;
  final EventDrawModel? existingDraw;

  static Future<void> show(
      BuildContext context, {
        required String eventId,
        required String type,
        EventDrawModel? existingDraw,
      }) async {
    final controller = Get.isRegistered<EventDrawController>()
        ? Get.find<EventDrawController>()
        : Get.put(EventDrawController());

    if (existingDraw != null) {
      controller.prefill(existingDraw);
    } else {
      controller.resetForm();
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: AddDrawBottomSheet(
            eventId: eventId,
            type: type,
            existingDraw: existingDraw,
          ),
        ),
      ),
    );
  }

  bool get isEdit => existingDraw != null;
  String get _typeLabel => type == 'draw' ? 'Draw' : 'Result';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventDrawController>();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          TSizes.defaultSpace,
          TSizes.defaultSpace,
          TSizes.defaultSpace,
          TSizes.defaultSpace + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
      
            // Header
            Row(
              children: [
                Icon(
                  type == 'draw' ? Iconsax.document : Iconsax.chart,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isEdit ? 'Edit $_typeLabel' : 'Upload $_typeLabel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: TSizes.spaceBtwItems),
      
            // Title field
            TextFormField(
              controller: controller.titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: '$_typeLabel Title *',
                hintText: type == 'draw'
                    ? 'e.g. Main Draw, Quarter Finals'
                    : 'e.g. Day 1 Results, Semi Finals',
                prefixIcon: const Icon(Iconsax.text, size: 18),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
      
            // Image picker
            Obx(() {
              final hasPicked = controller.pickedImage.value != null;
              final hasExisting = controller.existingImageUrl.value.isNotEmpty;
      
              return GestureDetector(
                onTap: controller.pickFile,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: hasPicked
                      ? ClipRRect(
                    borderRadius:
                    BorderRadius.circular(TSizes.cardRadiusMd),
                    child: Image.file(
                      controller.pickedImage.value!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : hasExisting
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            TSizes.cardRadiusMd),
                        child: Image.network(
                          controller.existingImageUrl.value,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(
                              TSizes.cardRadiusMd),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.camera,
                                color: Colors.white, size: 28),
                            SizedBox(height: 6),
                            Text('Tap to change',
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.image,
                          size: 36, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload $_typeLabel image',
                        style:
                        const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PNG, JPG supported',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: TSizes.spaceBtwSections),
      
            // Submit
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => isEdit
                    ? controller.updateDraw(
                    existingDraw!, eventId, context)
                    : controller.addDraw(eventId, type, context),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                child: controller.isLoading.value
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEdit
                    ? 'Update $_typeLabel'
                    : 'Upload $_typeLabel'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}