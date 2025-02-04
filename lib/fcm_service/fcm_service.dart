import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

@injectable
class FCMService {
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    // sound: RawResourceAndroidNotificationSound('notify'),
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _getPermissions();
    await _initializeBackgroundMessage();
    await _initializeLocalMessage();
    await _messageTerminatedHandler();
    await getFirebaseToken();
  }

  Future<void> _getPermissions() async {
    try {
      await _fcm.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
    } catch (e) {
      log('Permission Error : $e', name: 'FCM');
    }
  }

  Future<String> getFirebaseToken() async {
    var token = '';
    try {
      token = (await _fcm.getToken())!;
      log(token, name: 'Firebase Token');
    } catch (e) {
      log('Get Token Error : $e', name: 'FCM');
    }
    return token;
  }

  // Method to unregister Firebase messaging token
  Future<void> unregisterToken() async {
    try {
      await _fcm.deleteToken();
    } catch (e) {
      log('Error unregistering Firebase messaging token: $e');
    }
  }

  // Method to re-register Firebase messaging token
  Future<void> registerToken() async {
    try {
      await _fcm.getToken();
    } catch (e) {
      log('Error registering Firebase messaging token: $e');
    }
  }

  Future<void> _initializeBackgroundMessage() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      //  FirebaseMessaging.onMessageOpenedApp.listen(_messageOpenedAppHandler);
      log('Background messaging initialized',
          name: 'FIREBASE BACKGROUND NOTIFICATION');
    } catch (e) {
      log('Background Services Initializing Error : $e',
          name: 'ERROR: FIREBASE BACKGROUND NOTIFICATION');
    }
  }

  Future<void> _initializeLocalMessage() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const initializationSettingsAndroid =
        AndroidInitializationSettings('drawable/ic_notification');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initialSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    // await _flutterLocalNotificationsPlugin.initialize(initialSettings);
    await _flutterLocalNotificationsPlugin.initialize(initialSettings,
        onDidReceiveNotificationResponse: (payload) async {
      // Handle notification click when the app is in foreground
      // RemoteMessage message = RemoteMessage(data: {"payload": payload});
      //  _messageOpenedAppHandlerForeground(message);
    });
    FirebaseMessaging.onMessage.listen(_foregroundMessageHandler);
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _foregroundMessageHandler(RemoteMessage message) async {
    // if (Platform.isAndroid) {
    final notification = message.notification;
    final androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      icon: 'drawable/ic_notification',
      importance: channel.importance,
      playSound: channel.playSound,
      sound: channel.sound,
    );
    const iosNotificationDetails = DarwinNotificationDetails(
      //  sound: 'notify.aiff',
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    );
    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        iOS: iosNotificationDetails,
        android: androidNotificationDetails,
      ),
      payload: message.data['payload'].toString(),
    );
    // }
  }

  Future<void> _messageTerminatedHandler() async {
    await _fcm.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null) {
        //TODO: Handle message on the terminated state of the app
      }
    });
  }

  // void _messageOpenedAppHandler(RemoteMessage message) {
  //   FCMNavigationService().init(message, false);
  //   log('Notification opened', name: 'FCM');
  // }
  //
  // void _messageOpenedAppHandlerForeground(RemoteMessage message) {
  //   FCMNavigationService().init(message, true);
  //   log('Notification opened', name: 'FCM');
  // }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
      //  options: DefaultFirebaseOptions.currentPlatform,
      );

  final receiver = ReceivePort();
  IsolateNameServer.registerPortWithName(receiver.sendPort, 'ringtone');
  receiver.listen((message) async {});
}
