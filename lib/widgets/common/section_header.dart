import 'package:flutter/material.dart';

/// Reusable dark banner header — used for "See Examples" style callouts,
/// or any full-width highlighted section label.
class SectionHeader1 extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;
  final Widget? trailingIcon;

  const SectionHeader1({
    super.key,
    required this.title,
    this.subtitle,
    this.backgroundColor = Colors.black,
    this.textColor = const Color(0xFFFFC72C),
    this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      trailingIcon!,
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}