import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fully generic, reusable app bar — covers text bars, logo bars,
/// back-nav, icon-only bars, and tabbed/search headers.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final String? title;
  final Widget? titleWidget; // overrides `title` if provided (e.g. logo image)
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? leftActions;
  final List<Widget>? rightActions;
  final double height;
  final double elevation;
  final Brightness statusBarIconBrightness;
  final PreferredSizeWidget? bottom; // e.g. TabBar or search field

  const CustomAppBar({
    super.key,
    this.backgroundColor = Colors.white,
    this.title,
    this.titleWidget,
    this.centerTitle = true,
    this.showBackButton = false,
    this.onBackPressed,
    this.leftActions,
    this.rightActions,
    this.height = 64,
    this.elevation = 0,
    this.statusBarIconBrightness = Brightness.dark,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarIconBrightness == Brightness.light
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: backgroundColor)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: backgroundColor),
      child: AppBar(
        backgroundColor: backgroundColor,
        elevation: elevation,
        centerTitle: centerTitle,
        automaticallyImplyLeading: false,
        toolbarHeight: height,
        titleSpacing: 0,
        leading: showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
        )
            : (leftActions != null && leftActions!.isNotEmpty
            ? Row(mainAxisSize: MainAxisSize.min, children: leftActions!)
            : null),
        leadingWidth: showBackButton ? null : (leftActions != null ? leftActions!.length * 48.0 : null),
        title: titleWidget ?? (title != null ? Text(title!) : null),
        actions: rightActions,
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));
}