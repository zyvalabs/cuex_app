import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../users/widgets/user_avatar_widget.dart';


class PlayerSelectCard extends StatelessWidget {
  const PlayerSelectCard({
    super.key,
    required this.label,
    this.playerId,
    this.playerName,
    this.playerImage,
    required this.onTap,
    this.isAutoFilled = false,
  });

  final String label;
  final String? playerId;
  final String? playerName;
  final String? playerImage;
  final VoidCallback onTap;
  final bool isAutoFilled;

  @override
  Widget build(BuildContext context) {
    final isSelected = playerName != null && playerName!.isNotEmpty;

    return GestureDetector(
      onTap: isAutoFilled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.08)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Row(
          children: [
            isSelected
                ? UserAvatarWidget(
              imageUrl: playerImage ?? '',
              fullName: playerName!,
              radius: 22,
            )
                : Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: const Icon(Iconsax.scan, size: 20, color: Colors.white),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSelected ? playerName! : 'Tap to select',
                    style: isSelected
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
                        : Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isAutoFilled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text('You', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
              )
            else if (isSelected)
              const Icon(Iconsax.edit, size: 16, color: Colors.grey)
            else
              const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}