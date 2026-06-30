// lib/core/common/widgets/promotion/feature_tile.dart

import 'package:flutter/material.dart';

class FeatureTile extends StatelessWidget {
  final String title;
  final String? subtitle; // optional
  final IconData icon;
  final Color? color;     // 👈 now optional

  const FeatureTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.color, // 👈 optional now
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? Colors.white; // 👈 fallback color

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tileColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: tileColor, size: 20),
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      subtitle: subtitle != null
          ? Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle!,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      )
          : null,
    );
  }
}
