import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medapp/db/read_medicins.dart';
import 'package:medapp/notifications.dart';
import 'package:medapp/ui/add_medic.dart';
import 'package:medapp/ui/home.dart';
import 'package:workmanager/workmanager.dart';

//Initialize notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await checkAndSendNotifications();
    return Future.value(true);
  });
}

Future<void> checkAndSendNotifications() async {
  final DateTime now = DateTime.now();
  final int day = now.day;
  final int month = now.month;
  final int year = now.year;
  final String currentHour = now.hour.toString();

  try {
    // Fetch today's medication data
    final snapshot = await readMedicinsforDate(day, month, year);

    for (var record in snapshot) {
      final MedicInfo info =
          const MedicInfo().fromString(record['data'].toString());

      // Check if the current date is within startDate and endDate
      final DateTime startDate =
          DateFormat('d MMMM yyyy').parse(info.startDate);
      final DateTime endDate = DateFormat('d MMMM yyyy').parse(info.endDate);

      if (now.isAfter(startDate) &&
          now.isBefore(endDate.add(const Duration(days: 1)))) {
        // Check if the current hour matches any time in the list
        for (String time in info.times) {
          if (time == currentHour) {
            // Send notification
            await NotificationService.sendNotification(info.name, time);
          }
        }
      }
    }
  } catch (e) {
    print("Error processing notifications: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initNotifications(); // Initialize notifications
  // Initialize WorkManager for background tasks
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Schedule periodic task
  Workmanager().registerPeriodicTask(
    'fetch_medic_data',
    'fetchMedicDataTask',
    frequency: const Duration(hours: 1),
  );

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
