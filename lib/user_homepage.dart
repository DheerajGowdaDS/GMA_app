import 'package:flutter/material.dart';
import 'auth_service.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Center the "Home" text
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 100.0), // ← Adjust this manually
            Text('Home', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        // Add logout icon in top-left
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            final authService = AuthService();
            await authService.clearTokens();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            // New Upload Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('New Upload', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 300),

            // Your Uploads Button
            OutlinedButton(
              onPressed: () {
                print('Your uploads button pressed');
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Your Uploads', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
