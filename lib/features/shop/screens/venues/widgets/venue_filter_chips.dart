import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/sizes.dart';

class VenueFilterChips extends StatelessWidget {
  const VenueFilterChips({super.key, required this.selected, required this.onSelected});

  final RxString selected;
  final void Function(String) onSelected;

  static const filters = ['All', 'Active', 'Inactive', 'Featured', 'Streaming'];

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selected.value == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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