import 'package:flutter/material.dart';

/// Reusable full-width button — use anywhere in the app.
/// Pass `isEnabled: false` (e.g. nothing selected yet) to auto grey it out.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isEnabled;

  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color textColor;
  final Color disabledTextColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isEnabled = true,
    this.backgroundColor = Colors.black,
    this.disabledBackgroundColor = const Color(0xFFE0E0E0),
    this.textColor = Colors.white,
    this.disabledTextColor = const Color(0xFF9E9E9E),
    this.height = 52,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? backgroundColor : disabledBackgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isEnabled ? textColor : disabledTextColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}