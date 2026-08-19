import 'package:flutter/material.dart';

/// Reusable square image-only tile — use for streaming platform selection
/// (YouTube, Facebook, Instagram, RTMP, Twitch, Save to Device, etc).
class PlatformOptionCard extends StatelessWidget {
  final String? imagePath;
  final IconData? icon; // fallback if no image provided
  final bool isSelected;
  final VoidCallback? onTap;

  final Color containerColor;
  final Color borderColor;
  final Color selectedBorderColor;
  final double borderRadius;
  final Color iconColor;

  const PlatformOptionCard({
    super.key,
    this.imagePath,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.containerColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.selectedBorderColor = Colors.black,
    this.borderRadius = 12,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected ? selectedBorderColor : borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: imagePath != null
              ? Image.asset(imagePath!, fit: BoxFit.contain)
              : Icon(icon ?? Icons.image, color: iconColor, size: 28),
        ),
      ),
    );
  }
}