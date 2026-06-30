import 'package:flutter/material.dart';
import '../../../../utils/constants/sizes.dart';

class TListLayout extends StatelessWidget {
  const TListLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorHeight = TSizes.spaceBtwItems,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double separatorHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: separatorHeight),
      itemBuilder: itemBuilder,
    );
  }
}

// Usage
