import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/video_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoProvider()),
      ],
      child: const MedicalHubApp(),
    ),
  );
}

class MedicalHubApp extends StatelessWidget {
  const MedicalHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedicalHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF0F7FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          elevation: 4,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
