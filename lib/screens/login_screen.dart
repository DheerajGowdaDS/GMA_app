import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure this is your doctor login form

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Image.asset(
                  'assets/logo.png',
                  height: 80,
                  width: 80,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'MedicalHub',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please choose your login type',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildLoginButton(
                context,
                title: 'User Login',
                color: Colors.blueAccent,
                onTap: () {
                  // TODO: Handle user login navigation
                },
              ),
              const SizedBox(height: 20),
              _buildLoginButton(
                context,
                title: 'Doctor Login',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context, {
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
