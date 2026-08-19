import 'package:flutter/material.dart';

/// Fully reusable horizontal option selector — a title/header + a row of
/// tappable chips. Use for "Number of Reds" (15/10/6), "Match Type"
/// (Solo/Singles/Doubles), "Practice or Event", or any similar single-select group.
class OptionSelectorWidget extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onSelected;

  final Color titleColor;
  final double titleFontSize;

  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color borderColor;
  final double chipBorderRadius;

  const OptionSelectorWidget({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.titleColor = Colors.black,
    this.titleFontSize = 14,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.white,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,
    this.borderColor = const Color(0xFFE0E0E0),
    this.chipBorderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = option == selectedOption;
            return GestureDetector(
              onTap: () => onSelected(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : unselectedColor,
                  borderRadius: BorderRadius.circular(chipBorderRadius),
                  border: Border.all(
                    color: isSelected ? selectedColor : borderColor,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? selectedTextColor : unselectedTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}