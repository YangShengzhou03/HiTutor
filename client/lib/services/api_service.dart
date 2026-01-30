import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:8080/api';
  static const String baseUrl = 'http://120.55.50.51/api';
  static String? _token;
  static String? _refreshToken;
  static bool _isRefreshing = false;
  static Completer<Map<String, dynamic>?>? _refreshCompleter;
  static int _refreshFailureCount = 0;
  static DateTime? _lastRefreshFailureTime;

  static void setToken(String token) {
    _token = token;
    StorageService.saveToken(token);
  }

  static void setRefreshToken(String refreshToken) {
    _refreshToken = refreshToken;
    StorageService.saveRefreshToken(refreshToken);
  }

  static Future<void> initTokens() async {
    _token = await StorageService.getToken();
    _refreshToken = await StorageService.getRefreshToken();
    
    if (_refreshToken != null) {
      await _checkAndRefreshTokenIfNeeded();
    }
  }

  static void clearToken() {
    _token = null;
    _refreshToken = null;
    StorageService.removeToken();
    StorageService.removeRefreshToken();
  }

  static Map<String, String> _getHeaders({bool needAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (needAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<dynamic> _handleResponse(http.Response response, {bool needAuth = false, String? originalMethod, String? originalUrl, String? originalBody}) async {
    try {
      if (response.statusCode == 204) {
        return {'success': true, 'data': null};
      }
      
      if (response.body.isEmpty) {
        throw Exception('响应体为空，状态码: ${response.statusCode}');
      }
      
      final body = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body is Map) {
          if (body.containsKey('success')) {
            if (body['success'] == true) {
              return body;
            } else {
              final message = body['message'] ?? '请求失败';
              throw Exception(message);
            }
          }
        }
        return body;
      } else {
        if (response.statusCode == 401) {
          if (needAuth && _refreshToken != null) {
            final now = DateTime.now();
            if (_lastRefreshFailureTime != null && 
                now.difference(_lastRefreshFailureTime!).inMinutes < 1 &&
                _refreshFailureCount >= 3) {
              clearToken();
              throw Exception('登录已过期，请重新登录');
            }
            
            if (_isRefreshing) {
              if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
                await _refreshCompleter!.future;
                if (_token != null) {
                  return await _retryRequest(originalMethod ?? 'GET', originalUrl ?? '', originalBody);
                }
              }
            } else {
              _isRefreshing = true;
              _refreshCompleter = Completer<Map<String, dynamic>?>();
              try {
                final refreshResponse = await _refreshAccessToken();
                if (!_refreshCompleter!.isCompleted) {
                  _refreshCompleter!.complete(refreshResponse);
                }
                _isRefreshing = false;
                _refreshFailureCount = 0;
                _lastRefreshFailureTime = null;
                if (refreshResponse != null) {
                  return await _retryRequest(originalMethod ?? 'GET', originalUrl ?? '', originalBody);
                } else {
                  clearToken();
                }
              } catch (e) {
                _isRefreshing = false;
                _refreshFailureCount++;
                _lastRefreshFailureTime = DateTime.now();
                if (!_refreshCompleter!.isCompleted) _refreshCompleter!.complete(null);
                clearToken();
              }
            }
          }
        }

        String errorMessage;
        if (body is Map) {
          errorMessage = body['message'] ?? '请求失败';
        } else {
          errorMessage = '请求失败';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('JSON解析错误: ${e.message}，响应体: ${response.body}');
      } else {
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>?> _refreshAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          setToken(data['accessToken']);
          setRefreshToken(data['refreshToken']);
          return data;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _checkAndRefreshTokenIfNeeded() async {
    if (_refreshToken == null) return;
    
    final claims = _parseTokenClaims(_refreshToken!);
    if (claims == null) return;
    
    final expiration = claims['exp'] as int?;
    if (expiration == null) return;
    
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(expiration * 1000);
    final now = DateTime.now();
    final daysUntilExpiration = expirationDate.difference(now).inDays;
    
    if (daysUntilExpiration <= 7) {
      await _refreshAccessToken();
    }
  }

  static Map<String, dynamic>? _parseTokenClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      var payload = parts[1];
      
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      
      final decoded = utf8.decode(base64.decode(payload));
      
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> _retryRequest(String method, String url, String? body) async {
    final request = http.Request(method, Uri.parse(url))
      ..headers.addAll(_getHeaders())
      ..body = body ?? '';

    final streamedResponse = await http.Client().send(request);
    final httpResponse = await http.Response.fromStream(streamedResponse);
    return await _handleResponse(httpResponse, needAuth: true, originalMethod: method, originalUrl: url, originalBody: body);
  }

  
  static Future<dynamic> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> loginByPassword(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login-password'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> loginBySms(String phone, String verificationCode, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login-sms'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'phone': phone,
        'verificationCode': verificationCode,
        'role': role,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh-token'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> register(
    String username,
    String password,
    String email,
    String role,
    String phone,
    String verificationCode,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'role': role,
        'phone': phone,
        'verificationCode': verificationCode,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<void> forgotPassword(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({'phone': phone}),
    );
    await _handleResponse(response);
  }

  static Future<void> resetPassword(
    String phone,
    String verificationCode,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'phone': phone,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      }),
    );
    await _handleResponse(response);
  }
  
  static Future<dynamic> checkLogin() async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/check-login'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<void> sendVerificationCode(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifications/send'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'phone': phone,
      }),
    );
    await _handleResponse(response);
  }

  static Future<void> verifyCode(String phone, String code, String type) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifications/verify'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'phone': phone,
        'code': code,
        'type': type,
      }),
    );
    await _handleResponse(response);
  }
  
  
  static Future<dynamic> getUser(String userId, {bool needAuth = false, String? actualUserId}) async {
    String url = '$baseUrl/users/$userId';
    if (userId == 'me' && actualUserId != null) {
      url = '$baseUrl/users/$userId?userId=$actualUserId';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(needAuth: needAuth),
    );
    final result = await _handleResponse(response, needAuth: needAuth, originalMethod: 'GET', originalUrl: url);
    return result;
  }

  static Future<dynamic> updateUserRole(String userId, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'PATCH', originalUrl: '$baseUrl/users/$userId/role', originalBody: jsonEncode(data));
  }

  static Future<dynamic> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/profile'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'PUT', originalUrl: '$baseUrl/users/$userId/profile', originalBody: jsonEncode(data));
  }

  static Future<dynamic> getTutors({
    int page = 0,
    int size = 10,
    String? subject,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    String url;
    if (latitude != null && longitude != null) {
      var uri = Uri.parse('$baseUrl/tutor-profiles/nearby').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': (radius ?? 20).toString(),
        if (subject != null) 'subject': subject,
      });
      url = uri.toString();
      final response = await http.get(uri, headers: _getHeaders(needAuth: false));
      return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: url);
    }
    
    var uri = Uri.parse('$baseUrl/tutor-profiles?page=$page&size=$size');
    if (subject != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'subject': subject,
      });
    }
    url = uri.toString();

    final response = await http.get(uri, headers: _getHeaders(needAuth: false));
    return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: url);
  }

  
  static Future<dynamic> getSubjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getActiveSubjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects/active'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> getStudentRequests({
    int page = 0,
    int size = 10,
    String? subject,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    String url;
    if (latitude != null && longitude != null) {
      var uri = Uri.parse('$baseUrl/student-requests/nearby').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': (radius ?? 20).toString(),
        if (subject != null) 'subject': subject,
      });
      url = uri.toString();
      final response = await http.get(uri, headers: _getHeaders(needAuth: false));
      return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: url);
    }
    
    var uri = Uri.parse('$baseUrl/student-requests?page=$page&size=$size');
    if (subject != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'subject': subject,
      });
    }
    url = uri.toString();

    final response = await http.get(uri, headers: _getHeaders(needAuth: false));
    return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: url);
  }

  static Future<dynamic> getStudentRequestById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests/$id'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: '$baseUrl/student-requests/$id');
  }

  static Future<dynamic> searchStudentRequests(
    String query, {
    int page = 0,
    int size = 10,
    String? location,
    String? subject,
  }) async {
    var uri = Uri.parse('$baseUrl/student-requests/search?q=$query&page=$page&size=$size');
    if (location != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'location': location,
      });
    }
    if (subject != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'subject': subject,
      });
    }

    final response = await http.get(uri, headers: _getHeaders(needAuth: false));
    return await _handleResponse(response);
  }

  static Future<dynamic> searchTutors(
    String query, {
    int page = 0,
    int size = 10,
    String? location,
    String? subject,
  }) async {
    var uri = Uri.parse('$baseUrl/users/tutors/search?q=$query&page=$page&size=$size');
    if (location != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'location': location,
      });
    }
    if (subject != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'subject': subject,
      });
    }

    final response = await http.get(uri, headers: _getHeaders(needAuth: false));
    return await _handleResponse(response);
  }

  static Future<dynamic> getService(String serviceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-profiles/$serviceId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createService(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutor-profiles'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'POST', originalUrl: '$baseUrl/tutor-profiles', originalBody: jsonEncode(data));
  }

  static Future<dynamic> updateService(
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tutor-profiles/$serviceId'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'PUT', originalUrl: '$baseUrl/tutor-profiles/$serviceId', originalBody: jsonEncode(data));
  }

  static Future<void> deleteService(String serviceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tutor-profiles/$serviceId'),
      headers: _getHeaders(needAuth: false),
    );
    await _handleResponse(response, needAuth: false, originalMethod: 'DELETE', originalUrl: '$baseUrl/tutor-profiles/$serviceId');
  }

  static Future<dynamic> createRequest(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student-requests'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'POST', originalUrl: '$baseUrl/student-requests', originalBody: jsonEncode(data));
  }

  static Future<void> deleteRequest(String requestId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/student-requests/$requestId'),
      headers: _getHeaders(needAuth: false),
    );
    await _handleResponse(response, needAuth: false, originalMethod: 'DELETE', originalUrl: '$baseUrl/student-requests/$requestId');
  }

  static Future<dynamic> getUserRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests/user'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: '$baseUrl/student-requests/user');
  }

  static Future<dynamic> getUserRequestsWithUserId(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests/user?userId=$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: '$baseUrl/student-requests/user?userId=$userId');
  }

  static Future<dynamic> getUserRequestsByUserId(String userId, {bool needAuth = false}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests/user/$userId'),
      headers: _getHeaders(needAuth: needAuth),
    );
    return await _handleResponse(response, needAuth: needAuth, originalMethod: 'GET', originalUrl: '$baseUrl/student-requests/user/$userId');
  }

  static Future<dynamic> getUserServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-profiles/user'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: '$baseUrl/tutor-profiles/user');
  }

  static Future<dynamic> getUserServicesWithUserId(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-profiles/user?userId=$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response, needAuth: false, originalMethod: 'GET', originalUrl: '$baseUrl/tutor-profiles/user?userId=$userId');
  }

  static Future<dynamic> getUserServicesByUserId(String userId, {bool needAuth = false}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-profiles/user/$userId'),
      headers: _getHeaders(needAuth: needAuth),
    );
    return await _handleResponse(response, needAuth: needAuth, originalMethod: 'GET', originalUrl: '$baseUrl/tutor-profiles/user/$userId');
  }

  
  static Future<dynamic> getReviews(String tutorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/tutor/$tutorId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getReviewsByUserId(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/user/$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createReview(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> getFavorites(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites/user/$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> addFavorite(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<void> removeFavorite(
    String userId,
    String targetId,
    String targetType,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites?userId=$userId&targetId=$targetId&targetType=$targetType'),
      headers: _getHeaders(needAuth: false),
    );
    await _handleResponse(response);
  }

  
  static Future<dynamic> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?page=$page&size=$size'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> markNotificationAsRead(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> markAllNotificationsAsRead() async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> deleteNotification(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }
  
  static Future<dynamic> getConversations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversations?userId=$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getMessages(
    String sessionId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversations/$sessionId/messages?page=$page&size=$size'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createConversation(
    String user1Id,
    String user2Id,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/conversations'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'user1Id': user1Id,
        'user2Id': user2Id,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> sendMessage(
    String sessionId,
    String senderId,
    String receiverId,
    String content, {
    String messageType = 'text',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/conversations/$sessionId/messages'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'messageType': messageType,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<void> markAsRead(String sessionId, String userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/messages/conversations/$sessionId/read?userId=$userId'),
      headers: _getHeaders(needAuth: false),
    );
    await _handleResponse(response);
  }

  
  static Future<dynamic> getBlacklist({String? userId}) async {
    var uri = Uri.parse('$baseUrl/blacklist');
    if (userId != null && userId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'userId': userId});
    }
    final response = await http.get(
      uri,
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> addToBlacklist(
    String blockedUserId,
    {String? userId}
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/blacklist'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        'blockedUserId': blockedUserId,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> removeFromBlacklist(String blockedUserId, {String? userId}) async {
    var uri = Uri.parse('$baseUrl/blacklist/$blockedUserId');
    if (userId != null && userId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'userId': userId});
    }
    final response = await http.delete(
      uri,
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> checkBlocked(String blockedUserId, {String? userId}) async {
    var uri = Uri.parse('$baseUrl/blacklist/check/$blockedUserId');
    if (userId != null && userId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'userId': userId});
    }
    final response = await http.get(
      uri,
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createApplication(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applications'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> updateApplicationStatus(
    dynamic applicationId,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/applications/${applicationId.toString()}/status'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode({'status': status}),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> confirmApplication(
    dynamic applicationId,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/applications/${applicationId.toString()}/confirm'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getApplicationsByRequestId(
    dynamic requestId,
    String requestType,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/applications/request/${requestId.toString()}/type/$requestType'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getApplicationsByApplicantId(
    String applicantId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/applications/applicant/$applicantId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> getUserOrders(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/user/$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTutorOrders(String tutorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/tutor/$tutorId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createOrder(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> updateOrder(
    String orderId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$orderId'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<void> deleteOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/appointments/$orderId'),
      headers: _getHeaders(needAuth: false),
    );
    await _handleResponse(response);
  }

  static Future<void> confirmOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$orderId/confirm'),
      headers: _getHeaders(needAuth: false),
    );
    await _handleResponse(response);
  }

  static Future<void> cancelOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$orderId/cancel'),
      headers: _getHeaders(needAuth: false),
    );
    await _handleResponse(response);
  }

  static Future<void> completeOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$orderId/complete'),
      headers: _getHeaders(needAuth: false),
    );
    await _handleResponse(response);
  }

  static Future<dynamic> getPointRecords(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/points/records?userId=$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTotalPoints(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/points/total?userId=$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response, needAuth: false);
  }

  static Future<dynamic> getUserStatistics(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/statistics'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTutorResume(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-resumes/user/$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> saveTutorResume(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutor-resumes'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTutorCertification(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-certifications/user/$userId'),
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> submitTutorCertification(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutor-certifications'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> createComplaint(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaints'),
      headers: _getHeaders(needAuth: false),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getComplaints({String? userId}) async {
    var uri = Uri.parse('$baseUrl/complaints/my');
    if (userId != null && userId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'userId': userId});
    }
    final response = await http.get(
      uri,
      headers: _getHeaders(needAuth: false),
    );
    return await _handleResponse(response);
  }
}
