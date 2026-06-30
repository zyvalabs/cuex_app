import 'package:flutter/material.dart';
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.isFullWidth = false,
    this.fontSize = 14,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool isFullWidth;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: isFullWidth ? const Size(double.infinity, 50) : null,
      ),
      child: Text(label, style: TextStyle(fontSize: fontSize)),
    );
  }
}