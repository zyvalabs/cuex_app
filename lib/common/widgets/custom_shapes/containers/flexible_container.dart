import 'package:flutter/cupertino.dart';

class TFlexibleContainer extends StatelessWidget {
  const TFlexibleContainer({
    super.key,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.child,
  });

  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        border: borderColor != null ? Border.all(color: borderColor!, width: borderWidth) : null,
      ),
      child: child,
    );
  }
}