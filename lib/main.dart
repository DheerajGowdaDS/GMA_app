import 'package:flutter/material.dart';
import 'screens/baby_form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Video App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BabyFormScreen(),
    );
  }
}
