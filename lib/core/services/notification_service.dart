import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mind_flow/core/services/firestore_service.dart';

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
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
    debugPrint('Bildirim geldi: \\${notification?.title}');
    debugPrint('Bildirim içeriği: \\${notification?.body}');
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Bildirime tıklandı!');
    // Burada yönlendirme veya başka bir işlem yapılabilir
  }

  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
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