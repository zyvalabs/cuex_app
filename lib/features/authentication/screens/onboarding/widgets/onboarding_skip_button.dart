import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../controllers/onboarding_controller.dart';

class TOnBoardingSkipButton extends StatelessWidget {
  const TOnBoardingSkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;

    return Positioned(
      top: TDeviceUtils.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: TextButton(
        onPressed: controller.skipPage,
        child: Text(
          'SKIP',
          style: GoogleFonts.bebasNeue(
            fontSize: 18,
            letterSpacing: 1.5,
            color: TColors.cream,
          ),
        ),
      ),
    );
  }
}
