import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/routes.dart';
import 'notification_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class TNotificationService extends GetxService {
  static TNotificationService get instance => Get.find();

  static const _functionUrl = 'https://us-central1-cuex-ab44c.cloudfunctions.net/notify';
  static const _timeout = Duration(seconds: 10);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<NotificationModel> notifications = [];

  @override
  void onInit() {
    super.onInit();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    if (Platform.isWindows) return; // Add this
    await requestPermission();
    _initializeLocalNotifications();
    _setupFirebaseListeners();
    await _saveTokenToFirestore();
    await _firebaseMessaging.subscribeToTopic('all_users');
    _firebaseMessaging.onTokenRefresh.listen((token) => _saveTokenToFirestore());
  }
  Future<void> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true, badge: true, sound: true,
      announcement: false, carPlay: false, criticalAlert: false, provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('⚠️ Notification permissions denied');
    }
  }

  static Future<String> getToken() async {
    await Future.delayed(const Duration(milliseconds: 5000));
    final token = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) print('FCM Token: $token');
    return token ?? '';
  }

  Future<void> _saveTokenToFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      final token = await _firebaseMessaging.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (kDebugMode) print('✅ FCM token saved to Firestore');
    } catch (e) {
      if (kDebugMode) print('❌ Error saving FCM token: $e');
    }
  }

  Future<void> subscribeToMatch(String matchId) async =>
      await _firebaseMessaging.subscribeToTopic('match_$matchId');

  Future<void> unsubscribeFromMatch(String matchId) async =>
      await _firebaseMessaging.unsubscribeFromTopic('match_$matchId');

  Future<void> subscribeToTournament(String tournamentId) async =>
      await _firebaseMessaging.subscribeToTopic('tournament_$tournamentId');

  Future<void> unsubscribeFromTournament(String tournamentId) async =>
      await _firebaseMessaging.unsubscribeFromTopic('tournament_$tournamentId');

  Future<void> sendToTokens({
    required List<String> tokens,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    await _callFunction({
      'action': 'sendToTokens',
      'tokens': tokens,
      'notification': {
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
      if (data != null) 'data': data,
    });
  }

  Future<void> sendToTopic({
    required String topic,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    await _callFunction({
      'action': 'sendToTopic',
      'topic': topic,
      'notification': {
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
      if (data != null) 'data': data,
    });
  }

  Future<void> notifyMatchCreated({
    required String matchId,
    required List<String> playerTokens,
    required String player1Name,
    required String player2Name,
    required String scheduledTime,
  }) async {
    await sendToTokens(
      tokens: playerTokens,
      title: 'Match Scheduled 🎱',
      body: '$player1Name vs $player2Name at $scheduledTime',
      data: {'type': 'match_created', 'matchId': matchId, 'route': TRoutes.matchDetails},
    );
  }

  Future<void> notifyMatchStarted({
    required String matchId,
    required String player1Name,
    required String player2Name,
  }) async {
    await sendToTopic(
      topic: 'match_$matchId',
      title: 'Match Started 🎱',
      body: '$player1Name vs $player2Name is now live!',
      data: {'type': 'match_started', 'matchId': matchId, 'route': TRoutes.matchDetails},
    );
  }

  Future<void> notifyHighBreak({
    required String matchId,
    required String playerName,
    required int score,
  }) async {
    await sendToTopic(
      topic: 'match_$matchId',
      title: '🔥 High Break - $score!',
      body: '$playerName just scored a $score break!',
      data: {'type': 'high_break', 'matchId': matchId, 'score': score.toString()},
    );
  }

  Future<void> notifyMatchWinner({
    required String matchId,
    required String winnerName,
    required List<String> playerTokens,
  }) async {
    await sendToTokens(
      tokens: playerTokens,
      title: 'Match Over 🏆',
      body: '$winnerName wins the match!',
      data: {'type': 'match_ended', 'matchId': matchId},
    );
    await sendToTopic(
      topic: 'match_$matchId',
      title: 'Match Over 🏆',
      body: '$winnerName wins the match!',
      data: {'type': 'match_ended', 'matchId': matchId},
    );
  }

  Future<void> notifyTournamentWinner({
    required String tournamentId,
    required String winnerName,
  }) async {
    await sendToTopic(
      topic: 'tournament_$tournamentId',
      title: 'Tournament Winner 🏆',
      body: '$winnerName wins the tournament!',
      data: {'type': 'tournament_winner', 'tournamentId': tournamentId},
    );
  }

  Future<void> notifyBookingConfirmed({
    required String token,
    required String venueName,
    required String tableNumber,
    required String time,
  }) async {
    await sendToTokens(
      tokens: [token],
      title: 'Booking Confirmed ✅',
      body: '$venueName - Table $tableNumber at $time',
      data: {'type': 'booking_confirmed'},
    );
  }

  void _initializeLocalNotifications() {
    if (Platform.isWindows) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_notification_icon');
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  void _setupFirebaseListeners() {
    FirebaseMessaging.onMessage.listen(_onMessageReceived);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  void _onMessageReceived(RemoteMessage message) async {
    _showLocalNotification(message);
  }

  void _onNotificationOpenedApp(RemoteMessage message) {
    _handleNotificationRedirect(message);
  }
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (Platform.isWindows) return;

    final String? route = message.data['route'];
    final String? parameter = message.data['matchId'] ?? message.data['id'];

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cuex_channel', 'CueX Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification_icon',
      color: Color(0xFF10B981),
    );
    final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformDetails,
      payload: route != null ? '$route?id=$parameter' : null,
    );
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    if (response.payload != null && response.payload!.isNotEmpty) {
      Get.toNamed(response.payload!);
    }
  }

  Future<void> handleInitialMessage() async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleNotificationRedirect(initialMessage);
  }

  void _handleNotificationRedirect(RemoteMessage message) {
    final String? route = message.data['route'];
    final String? parameter = message.data['matchId'] ?? message.data['id'];
    if (route != null) {
      Get.toNamed(route, parameters: {'id': parameter ?? ''});
    } else {
      Get.toNamed(TRoutes.notification);
    }
  }

  void addNotification(RemoteMessage message, {String? route, String? routeId}) {
    final notification = NotificationModel(
      id: message.messageId ?? '',
      title: message.notification?.title ?? 'No Title',
      body: message.notification?.body ?? 'No Body',
      route: route ?? '',
      routeId: routeId ?? '',
      createdAt: DateTime.now(),
      seenBy: {},
      isBroadcast: false,
      type: message.data['type'] ?? '',
      recipientIds: [],
      senderId: '',
    );
    notifications.add(notification);
  }

  Future<void> _callFunction(Map<String, dynamic> body) async {
    try {
      debugPrint('📤 Calling function: $_functionUrl');
      debugPrint('📤 Body: ${jsonEncode(body)}');
      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout, onTimeout: () => throw Exception('Notification timed out'));
      if (kDebugMode) print('📩 Notification response: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Notification error: $e');
    }
  }
}