

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

/// Create match banner shown when 2 players selected
class CreateMatchBanner extends StatelessWidget {
  const CreateMatchBanner({
    required this.count,
    required this.onCreateMatch,
  });

  final int count;
  final VoidCallback onCreateMatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.defaultSpace, vertical: 10),
      color: TColors.primary.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$count selected',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton.icon(
            onPressed: onCreateMatch,
            icon: const Icon(Iconsax.add, size: 16),
            label: const Text('Create Match'),
          ),
        ],
      ),
    );
  }
}