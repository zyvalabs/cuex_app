import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class TSearchBar extends StatelessWidget {
  const TSearchBar({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.controller,
    this.onTap,
    this.readOnly = false,
  });

  final String hint;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Iconsax.search_normal, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
      ),
    );
  }
}