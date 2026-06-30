// shared/widgets/buttons/app_button.dart
import 'package:flutter/material.dart';




/// Reusable button widget
/// Use cases: Login, Register, Submit forms, Add to cart, Checkout, 
/// Delete, Save, Cancel, Confirm actions, Navigation buttons
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // null = disabled state
  final bool isLoading; // Shows loading spinner
  final bool isOutlined; // Outlined style vs filled
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon; // Optional leading icon
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-disable if loading or onPressed is null
    final bool isDisabled = isLoading || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity, // Full width by default
      height: height ?? 56,
      child: isOutlined
          ? OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: backgroundColor ?? Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonChild(context),
      )
          : ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonChild(context),
      ),
    );
  }

  // Builds button content with loading/icon states
  Widget _buildButtonChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(
            text,

          ),
        ],
      );
    }

    return Text(
      text,

    );
  }
}