import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/// Light & Dark Elevated Button Themes
class TElevatedButtonTheme {
  TElevatedButtonTheme._(); // Prevent instantiation

  /// Light Theme
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,

      // Text color
      foregroundColor: Colors.white,

      // Button color (Brand)
      backgroundColor: TColors.june,

      disabledForegroundColor: TColors.darkGrey,
      disabledBackgroundColor: TColors.buttonDisabled,

      side: const BorderSide(color: TColors.june),

      padding: const EdgeInsets.symmetric(
        vertical: TSizes.buttonHeight,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),

      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  /// Dark Theme
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,

      // Text color
      foregroundColor: Colors.white,

      // Button color (Brand)
      backgroundColor: TColors.june,

      disabledForegroundColor: TColors.darkGrey,
      disabledBackgroundColor: TColors.darkerGrey,

      side: const BorderSide(color: TColors.june),

      padding: const EdgeInsets.symmetric(
        vertical: TSizes.buttonHeight,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),

      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
