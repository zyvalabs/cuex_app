import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

class TLoaders {
  static hideSnackBar() => ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: THelperFunctions.isDarkMode(Get.context!) ? TColors.darkerGrey.withValues(alpha: 0.9) : TColors.grey.withValues(alpha: 0.9),
          ),
          child: Center(child: Text(message, style: Theme.of(Get.context!).textTheme.labelLarge)),
        ),
      ),
    );
  }

  static successSnackBar({required String title, String message = '', int duration = 3}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        duration: Duration(seconds: duration),
        backgroundColor: TColors.primary,
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        content: Row(
          children: [
            const Icon(Iconsax.check, color: TColors.white),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (message.isNotEmpty) Text(message, style: const TextStyle(color: Colors.white)),
            ])),
          ],
        ),
      ),
    );
  }

  static warningSnackBar({required String title, String message = ''}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        content: Row(
          children: [
            const Icon(Iconsax.warning_2, color: TColors.white),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (message.isNotEmpty) Text(message, style: const TextStyle(color: Colors.white)),
            ])),
          ],
        ),
      ),
    );
  }

  static errorSnackBar({required String title, String message = ''}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade600,
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        content: Row(
          children: [
            const Icon(Iconsax.warning_2, color: TColors.white),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (message.isNotEmpty) Text(message, style: const TextStyle(color: Colors.white)),
            ])),
          ],
        ),
      ),
    );
  }
}