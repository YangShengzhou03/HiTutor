import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isFirstLogin = true;
  Timer? _tokenRefreshTimer;
  bool _isRefreshingToken = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthenticated => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isFirstLogin => _isFirstLogin;

  
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = await StorageService.getToken();
      final savedRefreshToken = await StorageService.getRefreshToken();
      final savedUserData = await StorageService.getUserData();
      final savedIsLoggedIn = await StorageService.isLoggedIn();
      final savedIsFirstLogin = await StorageService.isFirstLogin();

      if (savedToken != null && savedIsLoggedIn) {
        _token = savedToken;
        _isLoggedIn = true;
        _isFirstLogin = savedIsFirstLogin;

        ApiService.setToken(savedToken);
        if (savedRefreshToken != null) {
          ApiService.setRefreshToken(savedRefreshToken);
        }

        if (savedUserData != null) {
          _user = User.fromJson(jsonDecode(savedUserData));
        } else {
          _user = await AuthService.getCurrentUser();
          if (_user != null) {
            await StorageService.saveUserData(jsonEncode(_user!.toJson()));
          }
        }

        await _checkDailyLogin();
        _startTokenRefreshTimer();
      }
    } catch (e) {
      await StorageService.clearUserData();
      _token = null;
      _user = null;
      _isLoggedIn = false;
      _isFirstLogin = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _checkDailyLogin() async {
    try {
      if (_token != null) {
        await ApiService.checkLogin();
      }
    } catch (e) {
      // 静默处理错误，因为这不是关键操作
    }
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _checkAndRefreshTokenIfNeeded();
    });
  }

  Future<void> _checkAndRefreshTokenIfNeeded() async {
    if (_token == null || _isRefreshingToken) return;
    
    try {
      final claims = _parseTokenClaims(_token!);
      if (claims == null) return;
      
      final expiration = claims['exp'] as int?;
      if (expiration == null) return;
      
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(expiration * 1000);
      final now = DateTime.now();
      final minutesUntilExpiration = expirationDate.difference(now).inMinutes;
      
      if (minutesUntilExpiration <= 5) {
        await _refreshToken();
      }
    } catch (e) {
      // 静默处理错误
    }
  }

  Map<String, dynamic>? _parseTokenClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      var payload = parts[1];
      
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      
      final decoded = const Utf8Decoder().convert(base64.decode(payload));
      
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> _refreshToken() async {
    if (_isRefreshingToken) return;
    
    _isRefreshingToken = true;
    
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return;
      
      final response = await ApiService.refreshToken(refreshToken);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _token = data['accessToken'];
        ApiService.setToken(_token!);
        await StorageService.saveToken(_token!);
        
        if (data['refreshToken'] != null) {
          ApiService.setRefreshToken(data['refreshToken']);
          await StorageService.saveRefreshToken(data['refreshToken']);
        }
      }
    } catch (e) {
      // 静默处理错误
    } finally {
      _isRefreshingToken = false;
    }
  }



  
  Future<void> loginWithRequest(Map<String, dynamic> request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.login(request);
      _token = response.accessToken;
      _isLoggedIn = true;
      _isFirstLogin = response.isFirstLogin;

      ApiService.setToken(_token!);
      ApiService.setRefreshToken(response.refreshToken);

      try {
        _user = await AuthService.getCurrentUser();
      } catch (e) {
        _user = response.user;
      }

      await StorageService.saveToken(_token!);
      await StorageService.saveRefreshToken(response.refreshToken);
      await StorageService.saveUserId(_user!.id);
      await StorageService.saveUserData(jsonEncode(_user!.toJson()));

      await StorageService.setLoggedIn(true);
      await StorageService.setFirstLogin(_isFirstLogin);

      _startTokenRefreshTimer();

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> register(Map<String, dynamic> request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.register(request);
      _token = response.accessToken;
      _user = response.user;
      _isLoggedIn = true;
      _isFirstLogin = response.isFirstLogin;

      await StorageService.saveToken(_token!);
      await StorageService.saveRefreshToken(response.refreshToken);
      await StorageService.saveUserId(_user!.id);
      await StorageService.saveUserData(jsonEncode(_user!.toJson()));

      await StorageService.setLoggedIn(true);
      await StorageService.setFirstLogin(_isFirstLogin);

      ApiService.setToken(_token!);
      ApiService.setRefreshToken(response.refreshToken);

      _startTokenRefreshTimer();

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> updateUserRole(String roleId, [String? userId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userToUse = _user ?? (userId != null ? User(id: userId, name: '', avatar: '', phone: '', email: '', createdAt: DateTime.now()) : null);
      if (userToUse == null) throw Exception('用户未登录');

      final request = {'roleId': roleId};
      await AuthService.updateUserRole(userToUse.id, request);

      _user = await AuthService.getCurrentUser();

      await StorageService.setFirstLogin(false);
      _isFirstLogin = false;

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();

    await StorageService.clearUserData();
    _token = null;
    _user = null;
    _isLoggedIn = false;
    _isFirstLogin = false;

    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;

    ApiService.clearToken();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> loginWithToken(dynamic userData, String token, {bool isFirstLogin = false, String? refreshToken}) async {
    _token = token;
    _isLoggedIn = true;
    _isFirstLogin = isFirstLogin;

    ApiService.setToken(token);
    if (refreshToken != null) {
      ApiService.setRefreshToken(refreshToken);
    }

    try {
      final tempUser = userData != null ? User.fromJson(userData) : null;
      _user = await AuthService.getCurrentUserWithUserId(tempUser?.id);
    } catch (e) {
      if (userData != null) {
        _user = User.fromJson(userData);
      }
    }

    await StorageService.saveToken(token);
    if (refreshToken != null) {
      await StorageService.saveRefreshToken(refreshToken);
    }
    await StorageService.saveUserId(_user!.id);
    await StorageService.saveUserData(jsonEncode(_user!.toJson()));
    await StorageService.setLoggedIn(true);
    await StorageService.setFirstLogin(isFirstLogin);

    notifyListeners();
  }
}
