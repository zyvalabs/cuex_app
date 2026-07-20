import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'data/repositories/authentication/authentication_repository.dart';
import 'data/services/analytics/app_analytics.dart';
import 'data/services/notifications/notification_service.dart';
import 'features/shop/screens/live streaming pedro/presentation/controllers/remote_streaming.dart';
import 'firebase_options.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── App Check — Android + iOS ──
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.debug, // switch to .deviceCheck for production
  );

  AppAnalytics.init();
  Get.put(AuthenticationRepository());
  Get.put(TNotificationService());
  Get.put(RemoteStreamCoordinator());

  debugPrint('✅ Firebase initialized with App Check');

  runApp(const App());
}