import 'package:flutter/material.dart';

import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class TLoginHeader extends StatelessWidget {
  const TLoginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button
        TRoundedContainer(
          padding: EdgeInsets.zero,
          backgroundColor: dark ? TColors.peppercorn : TColors.tyrolean,
          child: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: dark ? TColors.feta : TColors.peppercorn,
              size: 20,
            ),
          ),
        ),


        Center(
          child: Image(
            height: 100,
            image: AssetImage(dark ? TImages.lightAppLogo : TImages.darkAppLogo),
          ),
        ),

        const SizedBox(height: TSizes.md),
        Text(TTexts.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: TSizes.sm),
        Text(TTexts.loginSubTitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
