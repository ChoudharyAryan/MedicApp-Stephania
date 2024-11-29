import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medapp/ui/functions.dart';
import 'package:medapp/ui/history_screen.dart';
import 'package:medapp/ui/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: const Color(0xFFB4D84C),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            hintStyle: subHeadingStyle,
          )),
      home: const Home(),
    );
  }
}
