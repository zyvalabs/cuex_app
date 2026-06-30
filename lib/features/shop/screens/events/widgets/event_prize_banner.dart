import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../models/event_model.dart';


class EventPrizeBanner extends StatelessWidget {
  const EventPrizeBanner({super.key, required this.event});
  final EventModel event;

  bool get _hasData =>
      (event.entryFee != null && event.entryFee! > 0) ||
          (event.prizePool != null && event.prizePool! > 0);

  @override
  Widget build(BuildContext context) {
    if (!_hasData) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Entry Fee
          if (event.entryFee != null && event.entryFee! > 0)
            Expanded(
              child: _PrizeTile(
                icon: Iconsax.ticket,
                label: 'Entry Fee',
                value: '₹${event.entryFee!.toStringAsFixed(0)}',
                color: Colors.orange,
              ),
            ),

          if (event.entryFee != null &&
              event.entryFee! > 0 &&
              event.prizePool != null &&
              event.prizePool! > 0)
            Container(
              width: 1,
              height: 40,
              color: Colors.white10,
              margin: const EdgeInsets.symmetric(horizontal: TSizes.md),
            ),

          // Prize Pool
          if (event.prizePool != null && event.prizePool! > 0)
            Expanded(
              child: _PrizeTile(
                icon: Iconsax.cup,
                label: 'Prize Pool',
                value: '₹${event.prizePool!.toStringAsFixed(0)}',
                color: Colors.amber,
              ),
            ),
        ],
      ),
    );
  }
}

class _PrizeTile extends StatelessWidget {
  const _PrizeTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}