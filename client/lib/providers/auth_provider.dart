import 'dart:async';
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

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthenticated => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isFirstLogin => _isFirstLogin;

  
  Future<void> initialize() async {
    Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });

    try {
      final savedToken = await StorageService.getToken();

      if (savedToken != null) {
        _token = savedToken;
        _isLoggedIn = true;
        ApiService.setToken(savedToken);

        try {
          _user = await AuthService.getCurrentUser();
          _isFirstLogin = false;
        } catch (e) {
          _isLoggedIn = false;
          _token = null;
          await StorageService.removeToken();
        }
      } else {
        _isLoggedIn = false;
      }
    } catch (e) {
      _token = null;
      _user = null;
      _isLoggedIn = false;
      _isFirstLogin = false;
    } finally {
      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });
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

      _user = await AuthService.getCurrentUser();

      await StorageService.saveToken(_token!);

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
      ApiService.setToken(_token!);

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
      final userToUse = _user ?? (userId != null ? User(id: userId, username: '', avatar: '', phone: '', email: '', createTime: DateTime.now()) : null);
      if (userToUse == null) throw Exception('用户未登录');
      if (_token == null) throw Exception('Token 未设置');

      ApiService.setToken(_token!);

      final request = {'roleId': roleId};
      await AuthService.updateUserRole(userToUse.id, request);

      _user = await AuthService.getCurrentUser();
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

    await StorageService.removeToken();
    _token = null;
    _user = null;
    _isLoggedIn = false;
    _isFirstLogin = false;

    ApiService.clearToken();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> loginWithToken(dynamic userData, String token, {bool isFirstLogin = false}) async {
    _token = token;
    _isLoggedIn = true;
    _isFirstLogin = isFirstLogin;

    ApiService.setToken(token);

    try {
      final tempUser = userData != null ? User.fromJson(userData) : null;
      _user = await AuthService.getCurrentUserWithUserId(tempUser?.id);
    } catch (e) {
      if (userData != null) {
        _user = User.fromJson(userData);
      }
    }

    if (_user == null) {
      _isLoggedIn = false;
      _token = null;
      _isFirstLogin = false;
      notifyListeners();
      return;
    }

    await StorageService.saveToken(token);

    notifyListeners();
  }
}
