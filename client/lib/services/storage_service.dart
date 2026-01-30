import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isFirstLoginKey = 'is_first_login';

  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  
  static Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  
  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await _prefs;
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> removeRefreshToken() async {
    final prefs = await _prefs;
    await prefs.remove(_refreshTokenKey);
  }

  
  static Future<void> saveUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  static Future<void> removeUserId() async {
    final prefs = await _prefs;
    await prefs.remove(_userIdKey);
  }

  
  static Future<void> saveUserData(String userData) async {
    final prefs = await _prefs;
    await prefs.setString(_userDataKey, userData);
  }

  static Future<String?> getUserData() async {
    final prefs = await _prefs;
    return prefs.getString(_userDataKey);
  }

  static Future<void> removeUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_userDataKey);
  }

  
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _prefs;
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  
  static Future<void> setFirstLogin(bool isFirstLogin) async {
    final prefs = await _prefs;
    await prefs.setBool(_isFirstLoginKey, isFirstLogin);
  }

  static Future<bool> isFirstLogin() async {
    final prefs = await _prefs;
    return prefs.getBool(_isFirstLoginKey) ?? false;
  }

  
  static Future<void> clearUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userDataKey);
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_isFirstLoginKey);
  }
}
