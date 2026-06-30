import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/news_controller.dart';

class NewsPublishToggle extends StatelessWidget {
  const NewsPublishToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NewsController>();
    return Obx(() => Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: SwitchListTile(
        secondary: Icon(
          Iconsax.global,
          size: 20,
          color: c.isPublished.value ? Theme.of(context).primaryColor : Colors.grey,
        ),
        title: const Text('Publish'),
        subtitle: Text(
          c.isPublished.value ? 'Visible to all players' : 'Saved as draft',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        value: c.isPublished.value,
        onChanged: (val) => c.isPublished.value = val,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.cardRadiusMd)),
      ),
    ));
  }
}