import 'package:flutter/material.dart';
import '../models/tutor_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class TutorProvider with ChangeNotifier {
  List<Tutor> _tutors = [];
  List<Tutor> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;

  List<Tutor> get tutors => _tutors;
  List<Tutor> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static String? _normalizeGender(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    final lower = raw.toLowerCase();
    if (lower == 'male' || lower == 'm' || raw == '男') return 'male';
    if (lower == 'female' || lower == 'f' || raw == '女') return 'female';
    return raw;
  }

  
  Future<void> getNearbyStudents({int page = 1, int limit = 10}) async {
    if (_isLoading && page != 1) return;

    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await ApiService.getStudentRequests(page: page - 1, size: limit);
      
      final data = response['data'] ?? {};
      
      final requestsData = data['content'] as List? ?? [];
      
      final students = requestsData.map((item) {
        final userVerified = _parseBool(item['userVerified']);
        
        return Tutor(
          id: item['id']?.toString() ?? '',
          user: User(
            id: item['userId']?.toString() ?? '',
            username: item['userName'] ?? item['childName'] ?? '学生需求',
            avatar: item['userAvatar'] ?? '',
            phone: '',
            email: '',
            gender: _normalizeGender(item['userGender']),
            badge: item['badge']?.toString(),
            isVerified: userVerified,
            teachingExperience: 0,
            createTime: DateTime.now(),
          ),
          subjects: item['subjectName'] != null 
              ? [Subject(id: item['subjectId'].toString(), name: item['subjectName'], icon: '')]
              : [],
          tags: [],
          rating: 0.0,
          reviewCount: 0,
          pricePerHour: '${item['hourlyRateMin'] ?? 0}-${item['hourlyRateMax'] ?? 0}',
          experience: '',
          educationBackground: item['childGrade'] ?? '',
          description: item['requirements'] ?? '',
          certifications: [],
          isAvailable: true,
          createTime: DateTime.now(),
          type: 'student_request',
          targetGradeLevels: [],
          latitude: item['latitude']?.toString(),
          longitude: item['longitude']?.toString(),
        );
      }).toList();
      
      if (page == 1) {
        _tutors = students;
      } else {
        _tutors.addAll(students);
      }

      _currentPage = page;
      final totalElements = data['totalElements'];
      _hasMore = totalElements != null && totalElements > (page * limit);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getNearbyStudentsByLocation({
    required double latitude,
    required double longitude,
    double radius = 20,
  }) async {
    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await ApiService.getStudentRequests(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      
      final studentsData = response['data'] as List? ?? [];
      
      final students = studentsData.map((item) {
        return Tutor(
          id: item['id']?.toString() ?? '',
          user: User(
            id: item['userId']?.toString() ?? '',
            username: item['userName'] ?? item['childName'] ?? '学生需求',
            avatar: item['userAvatar'] ?? '',
            phone: '',
            email: '',
            gender: _normalizeGender(item['userGender']),
            badge: item['badge']?.toString(),
            isVerified: _parseBool(item['userVerified']),
            teachingExperience: 0,
            createTime: DateTime.now(),
          ),
          subjects: item['subjectName'] != null 
              ? [Subject(id: item['subjectId'].toString(), name: item['subjectName'], icon: '')]
              : [],
          tags: [],
          rating: 0.0,
          reviewCount: 0,
          pricePerHour: '${item['hourlyRateMin'] ?? 0}-${item['hourlyRateMax'] ?? 0}',
          experience: '',
          educationBackground: item['childGrade'] ?? '',
          description: item['requirements'] ?? '',
          certifications: [],
          isAvailable: true,
          createTime: DateTime.now(),
          type: 'student_request',
          targetGradeLevels: [],
          latitude: item['latitude']?.toString(),
          longitude: item['longitude']?.toString(),
        );
      }).toList();
      
      _tutors = students;
      _hasMore = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> getNearbyTutors({int page = 1, int limit = 10}) async {
    if (_isLoading && page != 1) return;

    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await ApiService.getTutors(page: page - 1, size: limit);
      
      final data = response['data'] ?? {};
      
      final tutorsData = data['content'] as List? ?? [];
      
      final tutors = tutorsData.map((item) {
        final userVerified = _parseBool(item['userVerified']);
        
        List<GradeLevel> gradeLevels = [];
        if (item['targetGradeLevels'] != null) {
          if (item['targetGradeLevels'] is List) {
            gradeLevels = (item['targetGradeLevels'] as List)
                .map((e) => GradeLevel.fromJson(e))
                .toList();
          } else if (item['targetGradeLevels'] is String) {
            final gradeLevelsStr = item['targetGradeLevels'].toString();
            if (gradeLevelsStr.isNotEmpty) {
              final gradeLevelIds = gradeLevelsStr.split(',');
              gradeLevels = gradeLevelIds
                  .map((id) => GradeLevel.allGradeLevels.firstWhere(
                        (gl) => gl.id == id,
                        orElse: () => GradeLevel(
                          id: id,
                          name: id,
                          displayName: id,
                        ),
                      ))
                  .toList();
            }
          }
        } else if (item['gradeLevels'] != null) {
          if (item['gradeLevels'] is List) {
            gradeLevels = (item['gradeLevels'] as List)
                .map((e) => GradeLevel.fromJson(e))
                .toList();
          } else if (item['gradeLevels'] is String) {
            final gradeLevelsStr = item['gradeLevels'].toString();
            if (gradeLevelsStr.isNotEmpty) {
              final gradeLevelIds = gradeLevelsStr.split(',');
              gradeLevels = gradeLevelIds
                  .map((id) => GradeLevel.allGradeLevels.firstWhere(
                        (gl) => gl.id == id,
                        orElse: () => GradeLevel(
                          id: id,
                          name: id,
                          displayName: id,
                        ),
                      ))
                  .toList();
            }
          }
        }
        
        return Tutor(
          id: item['id']?.toString() ?? '',
          user: User(
            id: item['userId']?.toString() ?? '',
            username: item['userName'] ?? item['username'] ?? '家教',
            avatar: item['userAvatar'] ?? '',
            phone: item['phone'] ?? '',
            email: item['email'] ?? '',
            gender: _normalizeGender(item['userGender']),
            badge: item['badge']?.toString(),
            teachingExperience: item['teachingExperience'] ?? 0,
            isVerified: userVerified,
            createTime: DateTime.now(),
          ),
          subjects: item['subjectName'] != null 
              ? [Subject(id: item['subjectId']?.toString() ?? '', name: item['subjectName'], icon: '')]
              : [],
          tags: [],
          rating: item['rating'] ?? 0.0,
          reviewCount: item['reviewCount'] ?? 0,
          pricePerHour: item['hourlyRate'] ?? '0',
          experience: item['teachingExperience'] ?? '',
          educationBackground: item['education'] ?? '',
          description: item['description'] ?? '',
          certifications: [],
          isAvailable: item['status'] == 'available',
          createTime: DateTime.now(),
          type: 'tutor_service',
          targetGradeLevels: gradeLevels,
          latitude: item['latitude']?.toString(),
          longitude: item['longitude']?.toString(),
        );
      }).toList();
      
      if (page == 1) {
        _tutors = tutors;
      } else {
        _tutors.addAll(tutors);
      }

      _currentPage = page;
      final totalElements = data['totalElements'];
      _hasMore = totalElements != null && totalElements > (page * limit);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> getNearbyTutorsByLocation({
    required double latitude,
    required double longitude,
    double radius = 20,
  }) async {
    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await ApiService.getTutors(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      
      final tutorsData = response['data'] as List? ?? [];
      
      final tutors = tutorsData.map((item) {
        List<GradeLevel> gradeLevels = [];
        if (item['targetGradeLevels'] != null) {
          if (item['targetGradeLevels'] is List) {
            gradeLevels = (item['targetGradeLevels'] as List)
                .map((e) => GradeLevel.fromJson(e))
                .toList();
          } else if (item['targetGradeLevels'] is String) {
            final gradeLevelsStr = item['targetGradeLevels'].toString();
            if (gradeLevelsStr.isNotEmpty) {
              final gradeLevelIds = gradeLevelsStr.split(',');
              gradeLevels = gradeLevelIds
                  .map((id) => GradeLevel.allGradeLevels.firstWhere(
                        (gl) => gl.id == id,
                        orElse: () => GradeLevel(
                          id: id,
                          name: id,
                          displayName: id,
                        ),
                      ))
                  .toList();
            }
          }
        } else if (item['gradeLevels'] != null) {
          if (item['gradeLevels'] is List) {
            gradeLevels = (item['gradeLevels'] as List)
                .map((e) => GradeLevel.fromJson(e))
                .toList();
          } else if (item['gradeLevels'] is String) {
            final gradeLevelsStr = item['gradeLevels'].toString();
            if (gradeLevelsStr.isNotEmpty) {
              final gradeLevelIds = gradeLevelsStr.split(',');
              gradeLevels = gradeLevelIds
                  .map((id) => GradeLevel.allGradeLevels.firstWhere(
                        (gl) => gl.id == id,
                        orElse: () => GradeLevel(
                          id: id,
                          name: id,
                          displayName: id,
                        ),
                      ))
                  .toList();
            }
          }
        }
        
        return Tutor(
          id: item['id']?.toString() ?? '',
          user: User(
            id: item['userId']?.toString() ?? '',
            username: item['userName'] ?? item['username'] ?? '家教',
            avatar: item['userAvatar'] ?? '',
            phone: item['phone'] ?? '',
            email: item['email'] ?? '',
            gender: _normalizeGender(item['userGender']),
            badge: item['badge']?.toString(),
            teachingExperience: item['teachingExperience'] ?? 0,
            isVerified: _parseBool(item['userVerified']),
            createTime: DateTime.now(),
          ),
          subjects: item['subjectName'] != null 
              ? [Subject(id: item['subjectId']?.toString() ?? '', name: item['subjectName'], icon: '')]
              : [],
          tags: [],
          rating: item['rating'] ?? 0.0,
          reviewCount: item['reviewCount'] ?? 0,
          pricePerHour: item['hourlyRate'] ?? '0',
          experience: item['teachingExperience'] ?? '',
          educationBackground: item['education'] ?? '',
          description: item['description'] ?? '',
          certifications: [],
          isAvailable: item['status'] == 'available',
          createTime: DateTime.now(),
          type: 'tutor_service',
          targetGradeLevels: gradeLevels,
        );
      }).toList();
      
      _tutors = tutors;
      _hasMore = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> searchStudents(String query, {int page = 1, int limit = 10}) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = '';

    try {
      final response = await ApiService.searchStudentRequests(query, page: page - 1, size: limit);
      final data = response['data'] ?? {};
      final resultsData = data['content'] as List? ?? [];
      
      final results = resultsData.map((item) {
        return Tutor.fromJson(item);
      }).toList();
      
      if (page == 1) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
      }

      _currentPage = page;
      final totalElements = data['totalElements'];
      _hasMore = totalElements != null && totalElements > (page * limit);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  
  Future<void> searchTutors(String query, {int page = 1, int limit = 10}) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = '';

    try {
      final response = await ApiService.searchTutors(query, page: page - 1, size: limit);
      final data = response['data'] ?? {};
      final resultsData = data['content'] as List? ?? [];
      
      final results = resultsData.map((item) {
        return Tutor.fromJson(item);
      }).toList();
      
      if (page == 1) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
      }

      _currentPage = page;
      final totalElements = data['totalElements'];
      _hasMore = totalElements != null && totalElements > (page * limit);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  
  void resetSearch() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  
  Future<void> loadMore(String role) async {
    if (!_hasMore || _isLoading) return;
    if (role == 'tutor') {
      await getNearbyStudents(page: _currentPage + 1);
    } else {
      await getNearbyTutors(page: _currentPage + 1);
    }
  }

  
  Future<void> refresh(String role) async {
    if (role == 'tutor') {
      await getNearbyStudents(page: 1);
    } else {
      await getNearbyTutors(page: 1);
    }
  }
}
