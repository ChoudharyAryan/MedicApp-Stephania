import 'dart:convert';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initNotifications() async {
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      log("Notification permissions denied.");
      return;
    }
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
    );
  }

  // Handle notification actions
  static void handleNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      final String action = data['action'];
      final String medicineName = data['medicine'];

      if (action == 'taken') {
        // Perform action for "Taken"
        print('Medicine "$medicineName" marked as taken.');
      } else if (action == 'skipped') {
        // Perform action for "Skipped"
        print('Medicine "$medicineName" marked as skipped.');
      }
    }
  }

  // Send a notification
  static Future<void> sendNotification(String medicineName, String time) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel',
      'Medication Notifications',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('taken', 'Taken'),
        AndroidNotificationAction('skipped', 'Skipped'),
      ],
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      'Medication Reminder',
      'Time to take your medicine: $medicineName at $time',
      platformChannelSpecifics,
      payload: jsonEncode({'action': 'none', 'medicine': medicineName}),
    );
  }
}
