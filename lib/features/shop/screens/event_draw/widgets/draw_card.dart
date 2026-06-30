import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/event_draw_model.dart';

class DrawCard extends StatelessWidget {
  const DrawCard({
    super.key,
    required this.draw,
    required this.isAdminOrPartner,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  final EventDrawModel draw;
  final bool isAdminOrPartner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Image
            draw.imageUrl.isNotEmpty
                ? Image.network(
              draw.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
                : _placeholder(),

            // Footer
            Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draw.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMM yyyy').format(draw.uploadedAt),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Admin actions
                  if (isAdminOrPartner) ...[
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Iconsax.edit, size: 18, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ] else ...[
                    Icon(Iconsax.maximize_3, size: 18, color: Colors.grey.shade600),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(Iconsax.image, size: 40, color: Colors.grey),
      ),
    );
  }
}