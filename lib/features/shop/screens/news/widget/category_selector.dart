import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/news_controller.dart';

class NewsCategorySelector extends StatelessWidget {
  const NewsCategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NewsController>();
    return Obx(() => DropdownButtonFormField<String>(
      value: c.selectedCategory.value,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Iconsax.category, size: 18),
      ),
      items: c.categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => c.selectedCategory.value = val ?? 'General',
    ));
  }
}