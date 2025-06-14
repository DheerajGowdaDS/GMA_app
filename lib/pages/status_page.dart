import 'package:flutter/material.dart';
import 'pending_page.dart';
import 'flagged_page.dart';
import 'approved_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Navigator',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Define named routes for better scalability
      routes: {
        '/': (_) => const StatusPage(),
        '/pending': (_) => const PendingPage(),
        '/flagged': (_) => const FlaggedPage(),
        '/approved': (_) => const ApprovedPage(),
      },
      initialRoute: '/',
    );
  }
}

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout: if width < 600, use column, else row
            final isNarrow = constraints.maxWidth < 600;

            return isNarrow
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusButton(
                        label: 'Pending',
                        color: Colors.orange,
                        icon: Icons.hourglass_bottom,
                        onTap: () {
                          Navigator.pushNamed(context, '/pending');
                        },
                      ),
                      const SizedBox(height: 20),
                      StatusButton(
                        label: 'Flagged',
                        color: Colors.red,
                        icon: Icons.flag,
                        onTap: () {
                          Navigator.pushNamed(context, '/flagged');
                        },
                      ),
                      const SizedBox(height: 20),
                      StatusButton(
                        label: 'Approved',
                        color: Colors.green,
                        icon: Icons.check_circle,
                        onTap: () {
                          Navigator.pushNamed(context, '/approved');
                        },
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: StatusButton(
                          label: 'Pending',
                          color: Colors.orange,
                          icon: Icons.hourglass_bottom,
                          onTap: () {
                            Navigator.pushNamed(context, '/pending');
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: StatusButton(
                          label: 'Flagged',
                          color: Colors.red,
                          icon: Icons.flag,
                          onTap: () {
                            Navigator.pushNamed(context, '/flagged');
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: StatusButton(
                          label: 'Approved',
                          color: Colors.green,
                          icon: Icons.check_circle,
                          onTap: () {
                            Navigator.pushNamed(context, '/approved');
                          },
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const StatusButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
