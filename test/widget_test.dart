import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctor_admin_panel/main.dart'; // adjust path if needed

void main() {
  testWidgets('App loads and displays login screen', (WidgetTester tester) async {
    // Load the app
    await tester.pumpWidget(const MedicalHubApp());

    // Check if text from login screen exists
    expect(find.text('MedicalHub'), findsOneWidget);
    expect(find.text('User Login'), findsOneWidget);
    expect(find.text('Doctor Login'), findsOneWidget);
  });
}
