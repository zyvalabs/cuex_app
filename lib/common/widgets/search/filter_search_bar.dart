import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class TFilterSearchBar extends StatelessWidget {
  const TFilterSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
          prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? GestureDetector(
              onTap: () {
                controller.clear();
                onChanged?.call('');
              },
              child: const Icon(Iconsax.close_circle, color: Colors.grey),
            )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: dark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
        ),
      ),
    );
  }
}