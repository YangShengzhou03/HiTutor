import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://120.55.50.51/api';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
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

  static Future<dynamic> _handleResponse(http.Response response) async {
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
        String errorMessage;
        if (body is Map) {
          switch (response.statusCode) {
            case 400:
              errorMessage = body['message'] ?? '请求参数错误';
              break;
            case 401:
              errorMessage = body['message'] ?? '未授权，请重新登录';
              break;
            case 403:
              errorMessage = body['message'] ?? '禁止访问';
              break;
            case 404:
              errorMessage = body['message'] ?? '资源不存在';
              break;
            case 409:
              errorMessage = body['message'] ?? '资源冲突';
              break;
            case 500:
              errorMessage = body['message'] ?? '服务器内部错误';
              break;
            default:
              errorMessage = body['message'] ?? '请求失败';
          }
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
      headers: _getHeaders(),
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
  
  
  static Future<dynamic> getUser(String userId, {bool needAuth = false}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _getHeaders(needAuth: needAuth),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> updateUserRole(String userId, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/role'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/profile'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTutors({
    int page = 0,
    int size = 10,
    String? subject,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    if (latitude != null && longitude != null) {
      var uri = Uri.parse('$baseUrl/tutor-profiles/nearby').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': (radius ?? 20).toString(),
        if (subject != null) 'subject': subject,
      });
      final response = await http.get(uri, headers: _getHeaders());
      return await _handleResponse(response);
    }
    
    var uri = Uri.parse('$baseUrl/tutor-profiles?page=$page&size=$size');
    if (subject != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'subject': subject,
      });
    }

    final response = await http.get(uri, headers: _getHeaders());
    return await _handleResponse(response);
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
    if (latitude != null && longitude != null) {
      var uri = Uri.parse('$baseUrl/student-requests/nearby').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': (radius ?? 20).toString(),
        if (subject != null) 'subject': subject,
      });
      final response = await http.get(uri, headers: _getHeaders());
      return await _handleResponse(response);
    }
    
    var uri = Uri.parse('$baseUrl/student-requests?page=$page&size=$size');
    if (subject != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'subject': subject,
      });
    }

    final response = await http.get(uri, headers: _getHeaders());
    return await _handleResponse(response);
  }

  static Future<dynamic> getStudentRequestById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests/$id'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
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

    final response = await http.get(uri, headers: _getHeaders());
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

    final response = await http.get(uri, headers: _getHeaders());
    return await _handleResponse(response);
  }

  
  static Future<dynamic> getServices({
    int page = 0,
    int size = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-profiles?page=$page&size=$size'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getService(String serviceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-profiles/$serviceId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createService(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutor-profiles'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> updateService(
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tutor-profiles/$serviceId'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<void> deleteService(String serviceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tutor-profiles/$serviceId'),
      headers: _getHeaders(),
    );
    await _handleResponse(response);
  }

  
  static Future<dynamic> getRequests({
    int page = 0,
    int size = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests?page=$page&size=$size'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getRequest(String requestId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests/$requestId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createRequest(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student-requests'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<void> deleteRequest(String requestId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/student-requests/$requestId'),
      headers: _getHeaders(),
    );
    await _handleResponse(response);
  }

  static Future<dynamic> getUserRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests/user'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getUserRequestsByUserId(String userId, {bool needAuth = false}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-requests/user/$userId'),
      headers: _getHeaders(needAuth: needAuth),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getUserServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-profiles/user'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getUserServicesByUserId(String userId, {bool needAuth = false}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-profiles/user/$userId'),
      headers: _getHeaders(needAuth: needAuth),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> getReviews(String tutorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/tutor/$tutorId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getReviewsByUserId(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/user/$userId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getReviewById(String reviewId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/$reviewId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createReview(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> getFavorites(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites/user/$userId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> addFavorite(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
    );
    await _handleResponse(response);
  }

  
  static Future<dynamic> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?page=$page&size=$size'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> markNotificationAsRead(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> markAllNotificationsAsRead() async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> deleteNotification(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> getConversations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversations?userId=$userId'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createConversation(
    String user1Id,
    String user2Id,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/conversations'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
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
      headers: _getHeaders(),
    );
    await _handleResponse(response);
  }

  
  static Future<dynamic> getBlacklist() async {
    final response = await http.get(
      Uri.parse('$baseUrl/blacklist'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> addToBlacklist(
    String blockedUserId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/blacklist'),
      headers: _getHeaders(),
      body: jsonEncode({
        'blockedUserId': blockedUserId,
      }),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> removeFromBlacklist(String blockedUserId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/blacklist/$blockedUserId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> checkBlocked(String blockedUserId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/blacklist/check/$blockedUserId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createApplication(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applications'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> confirmApplication(
    dynamic applicationId,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/applications/${applicationId.toString()}/confirm'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getApplicationsByRequestId(
    dynamic requestId,
    String requestType,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/applications/request/${requestId.toString()}/type/$requestType'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getApplicationsByApplicantId(
    String applicantId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/applications/applicant/$applicantId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> getUserOrders(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/user/$userId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTutorOrders(String tutorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/tutor/$tutorId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getOrder(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/$orderId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> createOrder(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: _getHeaders(),
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
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<void> deleteOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/appointments/$orderId'),
      headers: _getHeaders(),
    );
    await _handleResponse(response);
  }

  static Future<void> confirmOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$orderId/confirm'),
      headers: _getHeaders(),
    );
    await _handleResponse(response);
  }

  static Future<void> cancelOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$orderId/cancel'),
      headers: _getHeaders(),
    );
    await _handleResponse(response);
  }

  static Future<void> completeOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/$orderId/complete'),
      headers: _getHeaders(),
    );
    await _handleResponse(response);
  }

  static Future<dynamic> getPointRecords(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/points/records?userId=$userId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTotalPoints(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/points/total?userId=$userId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTutorResume(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-resumes/user/$userId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> saveTutorResume(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutor-resumes'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getTutorCertification(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tutor-certifications/user/$userId'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> submitTutorCertification(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutor-certifications'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  
  static Future<dynamic> createComplaint(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaints'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return await _handleResponse(response);
  }

  static Future<dynamic> getComplaints() async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaints/my'),
      headers: _getHeaders(),
    );
    return await _handleResponse(response);
  }
}
