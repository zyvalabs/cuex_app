import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';
import 'shimmer.dart';
class TMatchCardShimmer extends StatelessWidget {
  const TMatchCardShimmer({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (_, __) => const SizedBox(
        width: double.infinity,
        height: 280, // Same as MatchCard height
        child: TShimmerEffect(width: double.infinity, height: 280),
      ),
    );
  }
}