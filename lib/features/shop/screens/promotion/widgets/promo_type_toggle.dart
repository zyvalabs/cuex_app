import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';

class PromoTypeToggle extends StatelessWidget {
  const PromoTypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final RxString selected;
  final void Function(String) onChanged;

  static const _types = [
    {'label': 'Image', 'value': 'image'},
    {'label': 'Video', 'value': 'video'},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: _types.map((t) {
          final isSelected = selected.value == t['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(t['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }
}