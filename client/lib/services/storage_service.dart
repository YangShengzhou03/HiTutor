import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> get _prefs async {
    if (_prefsInstance != null) {
      return _prefsInstance!;
    }
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    final token = prefs.getString(_tokenKey);
    return token;
  }

  static Future<void> removeToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
