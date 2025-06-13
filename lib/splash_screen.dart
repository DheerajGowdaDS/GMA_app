import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final authService = AuthService();
    final userType = await authService.getCurrentUserType();

    if (userType != null) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(
          context,
          userType == 'user' ? '/user_home' : '/doctor_home',
        );
      });
    } else {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/welcome');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'HealthConnect',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
