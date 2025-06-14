import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<Map<String, dynamic>>> fetchVideos(String status) async {
    final response = await http.get(
      Uri.parse('http://<your-server>/api/videos/$status'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
