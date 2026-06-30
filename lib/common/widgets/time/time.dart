import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class TTimePicker extends StatelessWidget {
  const TTimePicker({
    super.key,
    required this.label,
    required this.time,
    required this.onChanged,
  });

  final String label;
  final RxString time;
  final void Function(String) onChanged;

  Future<void> _pick(BuildContext context) async {
    final parts = time.value.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        ),
        child: Row(
          children: [
            Icon(Iconsax.clock, size: 18, color: time.value.isNotEmpty ? Theme.of(context).primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(time.value.isNotEmpty ? time.value : '--:--', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    ));
  }
}