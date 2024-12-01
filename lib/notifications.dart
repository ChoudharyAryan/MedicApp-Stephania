// import 'dart:convert';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tzData;
// import 'package:permission_handler/permission_handler.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initNotifications() async {
//     tzData.initializeTimeZones(); // Initialize timezone data

//     // Request permission for notifications on Android 13+
//     if (await Permission.notification.isDenied) {
//       await Permission.notification.request();
//     }

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings settings =
//         InitializationSettings(android: androidSettings);

//     // Define notification channel explicitly
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'test_channel',
//       'Test Notifications',
//       description: 'Notifications for testing.',
//       importance: Importance.max,
//     );

//     // Create the notification channel for Android 8.0 and above
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     await _notificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (response) async {
//         final action = response.actionId;
//         final payload = response.payload;
//         if (payload != null) {
//           await handleNotificationAction(action, payload);
//         }
//       },
//     );
//   }

//   static Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//     required Map<String, dynamic> payload,
//   }) async {
//     try {
//       await _notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(scheduledTime, tz.local),
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'test_channel',
//             'Test Notifications',
//             channelDescription: 'Notifications for testing.',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//         ),
//         payload: jsonEncode(payload),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//       );
//     } catch (e) {
//       print('Error scheduling notification: $e');
//     }
//   }

//   static Future<void> handleNotificationAction(
//       String? action, String? payload) async {
//     if (payload != null) {
//       final Map<String, dynamic> data = jsonDecode(payload);
//       final String name = data['name'];
//       final String time = data['time'];
//       final String date = data['date'];

//       // Process the action (e.g., update your medication history)
//       print('Action: $action, Medication: $name, Time: $time, Date: $date');
//     }
//   }

//   static Future<void> sendTestNotification() async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'test_channel',
//       'Test Notifications',
//       channelDescription: 'Notifications for testing.',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidDetails);

//     await _notificationsPlugin.show(
//       0,
//       'Test Notification',
//       'This is a test notification!',
//       notificationDetails,
//       payload: jsonEncode({
//         'name': 'Paracetamol',
//         'time': '10:00 AM',
//         'date': DateTime.now().toString(),
//       }),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  static Future<void> initNotifications() async {
    tzData.initializeTimeZones(); // Initialize timezone data

    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    // Define the notification channel for Android 8.0 and above
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_channel',
      'Medication Notifications',
      description: 'Notifications for scheduled medications',
      importance: Importance.max,
    );

    // Create the notification channel
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize notification plugin with custom handler for actions
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        final action = response.actionId;
        final payload = response.payload;
        if (payload != null) {
          // Call the handler function to process the action
          await handleNotificationAction(action, payload);
        }
      },
    );
  }

  // Schedule a notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Notifications',
            channelDescription: 'Notifications for scheduled medications',
            importance: Importance.max,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction('taken', 'Taken'),
              AndroidNotificationAction('skipped', 'Skipped'),
            ],
          ),
        ),
        payload: jsonEncode(payload),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Handle action when user interacts with the notification
  static Future<void> handleNotificationAction(
      String? action, String? payload) async {
    if (payload != null) {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String name = data['name'];
      final String time = data['time'];
      final String date = data['date'];

      // Process the action (e.g., update medication history)
      print('Action: $action, Medication: $name, Time: $time, Date: $date');
    }
  }

  // // Send a test notification
  // static Future<void> sendTestNotification() async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //     'medication_channel',
  //     'Medication Notifications',
  //     channelDescription: 'Notifications for scheduled medications',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   const NotificationDetails notificationDetails =
  //       NotificationDetails(android: androidDetails);

  //   await _notificationsPlugin.show(
  //     0,
  //     'Test Notification',
  //     'This is a test notification!',
  //     notificationDetails,
  //     payload: jsonEncode({
  //       'name': 'Paracetamol',
  //       'time': '10:00 AM',
  //       'date': DateTime.now().toString(),
  //     }),
  //   );
  // }
}
