import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class OnBoardingPage extends StatelessWidget {
  /// Widget for displaying content on an onboarding page.
  const OnBoardingPage({
    super.key,
    required this.media,
    required this.title,
    required this.subTitle,
    this.isLottie = false,
  });

  final String media;
  final String title;
  final String subTitle;
  final bool isLottie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        children: [

          /// Media Section (Image or Lottie)
          SizedBox(
            width: THelperFunctions.screenWidth() * 0.8,
            height: THelperFunctions.screenHeight() * 0.6,
            child: isLottie
                ? Lottie.asset(media)
                : Image.asset(
              media,
              fit: BoxFit.contain,
            ),
          ),

          /// Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: TSizes.spaceBtwItems),

          /// Subtitle
          Text(
            subTitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}