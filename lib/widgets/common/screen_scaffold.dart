import 'package:flutter/material.dart';

/// Shared scaffold wrapper — keeps background color and app bar consistent
/// across screens without repeating Scaffold boilerplate everywhere.
class ScreenScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color backgroundColor;

  const ScreenScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor = const Color(0xFFF2F2F2),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: SafeArea(child: body),
    );
  }
}