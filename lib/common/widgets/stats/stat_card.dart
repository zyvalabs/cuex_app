import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = TColors.primary,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class StatCardsGrid extends StatelessWidget {
  const StatCardsGrid({super.key, required this.stats});

  final List<StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: TSizes.md,
        mainAxisSpacing: TSizes.md,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (_, index) => StatCard(
        title: stats[index].title,
        value: stats[index].value,
        icon: stats[index].icon,
        color: stats[index].color ?? TColors.primary,
      ),
    );
  }
}

class StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });
}