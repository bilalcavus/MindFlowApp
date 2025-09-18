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
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      
    );

    // Combined initialization
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Bildirim tıklandı: ${details.payload}');
      },
    );

    // İzinleri iste
    await requestPermission();

    Future<void> retrieveSaveFcmToken() async {
      final token = await getSafeFcmToken();
      try {
        if (token != null) {
          await _saveFcmTokenToFirestore(token: token);
        }
      } catch (e) {
        debugPrint('FCM token alınamadı: $e');
      }
    }

    retrieveSaveFcmToken();

    

    // // APNs token al (iOS)
    // if (Platform.isIOS) {
    //   String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    //   debugPrint('APNs token: $apnsToken');
    // }

    // // FCM token al ve kaydet
    // await _saveFcmTokenToFirestore();

    // // Token yenilenmesini dinle
    // listenTokenRefresh((newToken) async {
    //   await _saveFcmTokenToFirestore(token: newToken);
    // });

    // Mesajları dinle
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  Future<void> _onMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && (android != null || Platform.isIOS)) {
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: android != null
              ? const AndroidNotificationDetails(
                  'default_channel',
                  'Genel',
                  icon: '@mipmap/mindflow_icon',
                  importance: Importance.max,
                  priority: Priority.high,
                )
              : null,
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Bildirime tıklandı!');
    // Burada yönlendirme veya başka bir işlem yapılabilir
  }

  Future<void> requestPermission() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('iOS notification permission: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        debugPrint('Android notification permission: $status');
      }
    }
  }

  Future<String?> getSafeFcmToken() async {
  if (Platform.isIOS) {
    // Kullanıcı izin verdiyse bekle ve APNs token hazır olana kadar loop
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {

      String? apnsToken;
      // APNs token 10 saniye boyunca kontrol edelim
      for (int i = 0; i < 10; i++) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(Duration(seconds: 1));
      }

      if (apnsToken == null) {
        debugPrint('APNs token alınamadı!');
        return null;
      }

      debugPrint('APNs token hazır: $apnsToken');
    } else {
      debugPrint('iOS notification izni reddedildi.');
      return null;
    }
  }

  // Artık FCM token alabiliriz
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM token: $fcmToken');
  return fcmToken;
}


  void listenTokenRefresh(Function(String) onRefresh) {
    FirebaseMessaging.instance.onTokenRefresh.listen(onRefresh);
  }

 Future<void> _saveFcmTokenToFirestore({String? token}) async {
  final userId = FirestoreService().currentUserId;
  final fcmToken = token ?? await getSafeFcmToken();
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
