import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../features/shop/controllers/book_table_controller.dart';


class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookTableController>();

    return Obx(() {
      final selectedDate = controller.selected.value;
      final now = DateTime.now();
      final dates = List.generate(30, (i) => now.add(Duration(days: i)));

      return SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final date = dates[index];
            final isSelected = date.day == selectedDate.day && date.month == selectedDate.month;

            return GestureDetector(
              onTap: () => controller.selected.value = date,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                decoration: BoxDecoration(
                  color: isSelected ? TColors.primary : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM').format(date),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}