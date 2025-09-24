import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const KintsugiApp());
}

class KintsugiApp extends StatelessWidget {
  const KintsugiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kintsugi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
