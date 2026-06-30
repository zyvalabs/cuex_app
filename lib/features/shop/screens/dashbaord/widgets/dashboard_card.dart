
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class TDashboardCard extends StatelessWidget {
  const TDashboardCard({
    super.key,
    required this.context,
    required this.title,
    required this.subTitle,
    required this.stats,
    this.icon = Iconsax.arrow_up_3,
    this.color = TColors.success,
    this.onTap,
    required this.headingIcon,
    required this.headingIconColor,
    required this.headingIconBgColor,
  });

  final BuildContext context;
  final String title, subTitle;
  final IconData icon, headingIcon;
  final Color color, headingIconColor, headingIconBgColor;
  final int stats;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(TSizes.lg),
      child: Column(
        children: [
          /// Heading
          Row(
            children: [
              TCircularIcon(
                icon: headingIcon,
                backgroundColor: headingIconBgColor,
                color: headingIconColor,
                size: TSizes.md,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              TSectionHeading(title: title, textColor: TColors.textSecondary),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subTitle, style: Theme.of(context).textTheme.headlineMedium),

              /// Right Side Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /// Indicator
                  SizedBox(
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: TSizes.iconSm),
                        Text(
                          '$stats%',
                          style: Theme.of(context).textTheme.titleLarge!.apply(color: color, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 135,
                    child: Text(
                      'Compared to Dec 2023',
                      style: Theme.of(context).textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
