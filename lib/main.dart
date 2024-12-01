// import 'package:flutter/material.dart';
// import 'package:medapp/notifications.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService.initNotifications(); // Initialize notifications
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Notification Test',
//       home: NotificationTestScreen(),
//     );
//   }
// }

// class NotificationTestScreen extends StatefulWidget {
//   @override
//   _NotificationTestScreenState createState() => _NotificationTestScreenState();
// }

// class _NotificationTestScreenState extends State<NotificationTestScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notification Test'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             // Send a test notification on button press
//             await NotificationService.sendTestNotification();
//           },
//           child: Text('Send Notification'),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medapp/notifications.dart';
import 'package:medapp/ui/home.dart';

// // Initialize notification plugin
// // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// //     FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initNotifications(); // Initialize notifications

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFB4D84C),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      home: const Home(),
    );
  }
}
