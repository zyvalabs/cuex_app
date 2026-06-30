import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/event_controller.dart';

class EventPrizesSection extends StatelessWidget {
  const EventPrizesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EventController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Prize Tiers', style: Theme.of(context).textTheme.titleSmall),
            TextButton.icon(
              onPressed: () => _showAddPrizeDialog(context, c),
              icon: const Icon(Iconsax.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: TSizes.sm),
        Obx(() => c.prizes.isEmpty
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TSizes.md),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          ),
          child: const Center(
            child: Text('No prize tiers added', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        )
            : Column(
          children: List.generate(c.prizes.length, (i) {
            final prize = c.prizes[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _rankColor(i).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _rankColor(i))),
                    ),
                  ),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prize['rank'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        if ((prize['amount'] ?? 0) > 0)
                          Text('₹${prize['amount']}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddPrizeDialog(context, c, index: i),
                    icon: const Icon(Iconsax.edit, size: 16, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => c.removePrize(i),
                    icon: const Icon(Iconsax.trash, size: 16, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
        )),
      ],
    );
  }

  Color _rankColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFFFD700); // gold
      case 1: return const Color(0xFFC0C0C0); // silver
      case 2: return const Color(0xFFCD7F32); // bronze
      default: return Colors.blue;
    }
  }

  void _showAddPrizeDialog(BuildContext context, EventController c, {int? index}) {
    final rankController = TextEditingController(text: index != null ? c.prizes[index]['rank'] : '');
    final amountController = TextEditingController(text: index != null && c.prizes[index]['amount'] != 0 ? c.prizes[index]['amount'].toString() : '');

    final suggestions = ['Winner', 'Runner Up', '3rd Place', 'Highest Break', 'Quarter Final', 'Best Newcomer'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(index != null ? 'Edit Prize' : 'Add Prize', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TSizes.md),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: suggestions.map((s) => GestureDetector(
                onTap: () => rankController.text = s,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(s, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              )).toList(),
            ),
            const SizedBox(height: TSizes.md),
            TextField(
              controller: rankController,
              decoration: const InputDecoration(labelText: 'Rank / Title', hintText: 'e.g. Winner, Highest Break'),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Prize Amount (Optional)', hintText: '0 for non-cash', prefixText: '₹ '),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (rankController.text.trim().isEmpty) return;
                  final amount = double.tryParse(amountController.text.trim());
                  if (index != null) {
                    c.updatePrize(index, rankController.text.trim(), amount);
                  } else {
                    c.addPrize(rankController.text.trim(), amount);
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: Text(index != null ? 'Update Prize' : 'Add Prize'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}