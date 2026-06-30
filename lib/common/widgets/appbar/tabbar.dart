import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_functions.dart';
class TTabBar extends StatelessWidget implements PreferredSizeWidget {
  const TTabBar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Material(
      color: TColors.peppercorn,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: TColors.cranberry,
        labelColor: dark ? TColors.feta : TColors.primary,
        unselectedLabelColor: TColors.darkGrey,

        // 👉 Bebas Neue font
        labelStyle: GoogleFonts.bebasNeue(
          fontSize: 28,
          letterSpacing: 1.2,
        ),
        unselectedLabelStyle: GoogleFonts.bebasNeue(
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
