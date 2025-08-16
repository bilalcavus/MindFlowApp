import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mind_flow/core/services/firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS için ek ayarlar eklenebilir
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await requestPermission();

    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    await _saveFcmTokenToFirestore();
    listenTokenRefresh((newToken) async {
      await _saveFcmTokenToFirestore(token: newToken);
    });
  }

  Future<void> _onMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Genel',
            icon: '@mipmap/mf_logo',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Bildirime tıklandı!');
    // Burada yönlendirme veya başka bir işlem yapılabilir
  }

  Future<void> requestPermission() async {
    if(Platform.isIOS){
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if(Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if(status.isGranted){
          debugPrint('Bildirim izni verildi');
        } else {
          debugPrint('Bildirim izni reddedildi');
        }
      }
    }
    // await FirebaseMessaging.instance.requestPermission();
  }

  Future<String?> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  void listenTokenRefresh(Function(String) onRefresh) {
    FirebaseMessaging.instance.onTokenRefresh.listen(onRefresh);
  }

  Future<void> _saveFcmTokenToFirestore({String? token}) async {
    final userId = FirestoreService().currentUserId;
    final fcmToken = token ?? await getFcmToken();
    if (userId != null && fcmToken != null) {
      final user = await FirestoreService().getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(fcmToken: fcmToken);
        await FirestoreService().createOrUpdateUser(updatedUser);
        debugPrint('FCM token Firestore kullanıcı dokümanına kaydedildi.');
      }
    }
  }
} 