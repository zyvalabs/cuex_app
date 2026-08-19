import 'package:flutter/material.dart';

/// Reusable labeled text field for entering player names.
/// Use for Player 1 / Player 2 / Player 3 / Player 4 inputs.
class PlayerNameField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  final Color labelColor;
  final double labelFontSize;
  final Color fieldBackgroundColor;
  final double borderRadius;

  const PlayerNameField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.labelColor = Colors.black,
    this.labelFontSize = 14,
    this.fieldBackgroundColor = const Color(0xFFF2F2F2),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: labelFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter name',
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}