// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your backend address.
  // If you run Node/Express on localhost and test on Android emulator, use 10.0.2.2.
  static const String _baseUrl = 'http://10.0.2.2:5000';

  /// Sends a POST /api/register request with name, phone, email, password.
  static Future<http.Response> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    final url = Uri.parse('$_baseUrl/api/register');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      }),
    );
  }

  /// Sends a POST /api/login request with email, password.
  static Future<http.Response> loginUser({
    required String email,
    required String password,
  }) {
    final url = Uri.parse('$_baseUrl/api/login');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }
}
