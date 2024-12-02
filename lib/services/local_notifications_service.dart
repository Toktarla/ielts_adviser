import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:proj_management_project/services/firestore_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'daily_motivation_channel',
      'Daily Motivation',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher'
  );

  static void initialize() async {
    tz.initializeTimeZones();
    const InitializationSettings initializationSettingsAndroid = InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher")
    );

    await _notificationsPlugin.initialize(
      initializationSettingsAndroid,
      onDidReceiveNotificationResponse: (details) {
        if (details.input != null) {
          print("onDidReceiveNotificationResponse, ${details.input} !!! ${details}");
        }
      },
    );
    final bool? granted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled();

    print(_notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission());
    print("Notification permission granted: $granted");
  }

  static Future<void> display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = const NotificationDetails(
        android: androidNotificationDetails
      );
      await _notificationsPlugin.show(id, message.notification?.title,
          message.notification?.body, notificationDetails,
          payload: message.data['route']);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> scheduleDailyMotivationalMessage() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_notification_channel',
      'Daily Motivations',
      channelDescription: 'Receive daily motivational messages',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final message = await FirestoreService().fetchRandomMotivationalMessage();
    final scheduledTime = _nextInstanceOfTime(15, 0);
    print("Scheduled time for notification: $scheduledTime");

    await _notificationsPlugin.zonedSchedule(
      0,
      'IELTS Adviser!',
      message,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily.
    );

    print("Notification scheduled successfully.");

  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

}