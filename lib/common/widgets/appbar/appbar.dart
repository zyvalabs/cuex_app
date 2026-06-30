import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../routes/routes.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_functions.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
    required this.showActions,
    required this.showSkipButton,
    this.actionIcon,
    this.actionOnPressed,
    this.bottom,
  });
  final PreferredSizeWidget? bottom;
  final Widget? title;
  final bool showBackArrow;
  final bool showActions;
  final bool showSkipButton;
  final IconData? leadingIcon;
  final IconData? actionIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final VoidCallback? actionOnPressed;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: title,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall,
        bottom: bottom,

      /// Leading (Flutter default navigation)
      leading: showBackArrow
          ? IconButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              TRoutes.navigation,
                  (route) => false,
            );
          }
        },
        icon: Icon(
          Iconsax.arrow_left_24,
          color: dark ? TColors.light : TColors.dark,
        ),
      )
          : leadingIcon != null
          ? IconButton(
        onPressed: leadingOnPressed,
        icon: Icon(
          leadingIcon,
          color: dark ? TColors.light : TColors.dark,
        ),
      )
          : null,

      /// Actions
      actions: showSkipButton
          ? [
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              TRoutes.navigation,
                  (route) => false,
            );
          },
          child: const Text(TTexts.skip),
        ),
      ]
          : showActions
          ? (actions ??
          [
            if (actionIcon != null)
              IconButton(
                onPressed: actionOnPressed,
                icon: Icon(
                  actionIcon,
                  color: dark ? TColors.light : TColors.dark,
                ),
              ),
          ])
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight() + (bottom?.preferredSize.height ?? 0));
}
