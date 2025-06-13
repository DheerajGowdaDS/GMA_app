import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'splash_screen.dart';
import 'user_homepage.dart';
import 'doctor_homepage.dart';
import 'welcome_screen.dart';
import 'user_login_pg.dart';
import 'doctor_login_pg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();

  final userType = await authService.getCurrentUserType();

  runApp(MyApp(userType: userType));
}

class MyApp extends StatelessWidget {
  final String? userType;

  const MyApp({Key? key, this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/user_login': (context) => UserLogin(),
        '/doctor_login': (context) => DoctorLogin(),
        '/user_home': (context) => UserHomePage(),
        '/doctor_home': (context) => DoctorHomePage(),
      },
    );
  }
}
