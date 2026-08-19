import 'package:flutter/material.dart';

/// Reusable section header — title + optional subtitle, fully configurable.
/// Use for "Choose Sport", "Select Format", or any section label across screens.
class SectionTitleWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color titleColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final Color subtitleColor;
  final double subtitleFontSize;
  final TextAlign textAlign;
  final EdgeInsetsGeometry padding;

  const SectionTitleWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.titleColor = Colors.black,
    this.titleFontSize = 18,
    this.titleFontWeight = FontWeight.w700,
    this.subtitleColor = Colors.grey,
    this.subtitleFontSize = 13,
    this.textAlign = TextAlign.left,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: textAlign == TextAlign.center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: textAlign,
            style: TextStyle(
              color: titleColor,
              fontSize: titleFontSize,
              fontWeight: titleFontWeight,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: textAlign,
              style: TextStyle(
                color: subtitleColor,
                fontSize: subtitleFontSize,
              ),
            ),
          ],
        ],
      ),
    );
  }
}