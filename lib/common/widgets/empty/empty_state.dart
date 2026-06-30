import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';

class TEmptyState extends StatelessWidget {
  const TEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor ?? Colors.grey.withOpacity(0.5)),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey.withOpacity(0.7)), textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}