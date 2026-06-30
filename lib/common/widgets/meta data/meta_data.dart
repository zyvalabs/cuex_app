import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../custom_shapes/containers/rounded_container.dart';
import '../texts/t_product_title_text.dart';

class TMetaData extends StatelessWidget {
  const TMetaData({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor,
    this.rows = const [],
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final List<MetaDataRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Badge (optional)
        if (badge != null)
          Row(
            children: [
              TRoundedContainer(
                backgroundColor: badgeColor ?? TColors.secondary,
                radius: TSizes.sm,
                padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
                child: Text(
                  badge!,
                  style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.black),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
            ],
          ),

        /// Title
        TProductTitleText(title: title),
        const SizedBox(height: TSizes.spaceBtwItems / 1.5),

        /// Subtitle (optional)
        if (subtitle != null) ...[
          Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: TSizes.spaceBtwItems / 1.5),
        ],

        /// Custom Rows
        ...rows.map((row) => Padding(
          padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems / 2),
          child: Row(
            children: [
              TProductTitleText(title: '${row.label}: ', smallSize: true),
              Text(row.value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        )),
      ],
    );
  }
}

class MetaDataRow {
  final String label;
  final String value;

  MetaDataRow({required this.label, required this.value});
}
