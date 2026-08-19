import 'package:flutter/material.dart';

/// Generic reusable card — title, subtitle, a preview widget (image/mock UI), and tap action.
/// Use anywhere: dashboard options, settings entries, feature tiles, etc.
class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? preview;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.preview,
    required this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (preview != null) ...[
                  const SizedBox(height: 28),
                  preview!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}