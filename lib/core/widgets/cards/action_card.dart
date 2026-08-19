import 'package:flutter/material.dart';

/// Fully reusable card — title, subtitle, image/placeholder, and styling all configurable.
/// Use for "Create New Live Stream", "Tournament Match", or any similar option card.
class StreamOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imagePath; // pass null to show placeholder instead
  final Color titleColor;
  final double titleFontSize;
  final Color subtitleColor;
  final double subtitleFontSize;
  final Color backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const StreamOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imagePath,
    this.titleColor = Colors.black,
    this.titleFontSize = 20,
    this.subtitleColor = Colors.grey,
    this.subtitleFontSize = 14,
    this.backgroundColor = Colors.white,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: subtitleColor,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: imagePath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(imagePath!, fit: BoxFit.cover, width: double.infinity),
                    )
                        : const Icon(Icons.image, color: Colors.grey, size: 32),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}