import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userTokenKey = 'user_token';
  static const String _doctorTokenKey = 'doctor_token';

  Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userTokenKey, token);
  }

  Future<void> saveDoctorToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_doctorTokenKey, token);
  }

  Future<String?> getCurrentUserType() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_userTokenKey)) {
      return 'user';
    } else if (prefs.containsKey(_doctorTokenKey)) {
      return 'doctor';
    }
    return null;
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userTokenKey);
    prefs.remove(_doctorTokenKey);
  }
}
