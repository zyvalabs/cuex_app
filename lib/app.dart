import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'bindings/general_bindings.dart';
import 'routes/app_routes.dart';
import 'utils/constants/colors.dart';
import 'utils/constants/text_strings.dart';
import 'utils/theme/theme.dart';
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = MediaQuery.of(context).platformBrightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return GetMaterialApp(
      title: TTexts.appName,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.dark, // ✅ always dark
      debugShowCheckedModeBanner: false,
      initialBinding: GeneralBindings(),
      getPages: AppRoutes.pages,
      home: Scaffold(
        body: Center(
          child: Lottie.asset('assets/logos/Traingle.json',
              height: 200,
              width: 200),
        ),
      ),
    );
  }
}