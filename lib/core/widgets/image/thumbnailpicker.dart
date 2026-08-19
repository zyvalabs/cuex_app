import 'package:flutter/material.dart';

/// Reusable tap-to-upload placeholder box — use for thumbnails, logos, or any image upload.
class ThumbnailPickerBox extends StatelessWidget {
  final String? imagePath; // null shows placeholder
  final VoidCallback? onTap;
  final double height;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;
  final double borderRadius;

  const ThumbnailPickerBox({
    super.key,
    this.imagePath,
    this.onTap,
    this.height = 160,
    this.backgroundColor = const Color(0xFFF2F2F2),
    this.iconColor = Colors.grey,
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: imagePath != null
            ? Image.asset(imagePath!, fit: BoxFit.cover, width: double.infinity)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              'Upload Thumbnail',
              style: TextStyle(color: iconColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}