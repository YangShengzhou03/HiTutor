import '../models/user_model.dart';
import 'api_service.dart';

class AuthResponse {
  final String token;
  final User user;
  final bool isFirstLogin;

  AuthResponse({
    required this.token,
    required this.user,
    required this.isFirstLogin,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
      isFirstLogin: json['isFirstLogin'] == true || json['isFirstLogin'] == 1,
    );
  }
}

class AuthService {
  static Future<AuthResponse> login(Map<String, dynamic> request) async {
    final response = await ApiService.login(
      request['email'],
      request['password'],
    );
    return AuthResponse.fromJson(response['data']);
  }

  static Future<AuthResponse> register(Map<String, dynamic> request) async {
    final response = await ApiService.register(
      request['username'],
      request['password'],
      request['email'],
      request['role'],
      request['phone'],
      request['verificationCode'],
    );
    return AuthResponse.fromJson(response['data']);
  }

  static Future<void> sendVerificationCode(String phone) async {
    await ApiService.sendVerificationCode(phone);
  }

  static Future<void> forgotPassword(Map<String, dynamic> request) async {
    await ApiService.forgotPassword(request['phone']);
  }

  static Future<void> resetPassword(Map<String, dynamic> request) async {
    await ApiService.resetPassword(
      request['phone'],
      request['verificationCode'],
      request['newPassword'],
    );
  }

  static Future<User> updateUserRole(String userId, Map<String, dynamic> request) async {
    try {
      final response = await ApiService.updateUserRole(userId, request);
      return User.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<User> getCurrentUser() async {
    final response = await ApiService.getUser('me', needAuth: true);
    return User.fromJson(response['data']);
  }

  static Future<void> logout() async {
    ApiService.clearToken();
  }
}
