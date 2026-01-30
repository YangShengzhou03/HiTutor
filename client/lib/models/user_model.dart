class User {
  final String id;
  final String username;
  final String avatar;
  final String phone;
  final String email;
  final String? gender;
  final String? birthDate;
  final int? teachingExperience;
  final String? role;
  final String? badge;
  final bool? isVerified;
  final DateTime createTime;
  final double? latitude;
  final double? longitude;
  final int? points;

  User({
    required this.id,
    required this.username,
    required this.avatar,
    required this.phone,
    required this.email,
    this.gender,
    this.birthDate,
    this.teachingExperience,
    this.role,
    this.badge,
    this.isVerified,
    required this.createTime,
    this.latitude,
    this.longitude,
    this.points,
  });

  
  String get userRole => role ?? 'student';

  
  String get teachingExperienceText => teachingExperience != null ? '$teachingExperience年' : '';

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString(),
      birthDate: json['birthDate']?.toString(),
      teachingExperience: json['teachingExperience'] is int ? json['teachingExperience'] : null,
      role: json['role']?.toString(),
      badge: json['badge']?.toString(),
      isVerified: _parseBool(json['isVerified']),
      createTime: _parseDateTime(json['createTime']),
      latitude: json['latitude'] is String ? double.tryParse(json['latitude']) : null,
      longitude: json['longitude'] is String ? double.tryParse(json['longitude']) : null,
      points: json['points'] is int ? json['points'] : null,
    );
    return user;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      
      final date = DateTime.tryParse(value);
      if (date != null) return date;
      
      final parts = value.split('T');
      if (parts.length >= 2) {
        final datePart = parts[0];
        final timePart = parts[1].split('.')[0]; 
        final combined = '$datePart $timePart';
        final parsed = DateTime.tryParse(combined);
        if (parsed != null) return parsed;
      }
      
      final spaceParts = value.split(' ');
      if (spaceParts.length >= 2) {
        final datePart = spaceParts[0];
        final timePart = spaceParts[1].split('.')[0];
        final combined = '$datePart $timePart';
        final parsed = DateTime.tryParse(combined);
        if (parsed != null) return parsed;
      }
      
      return DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'phone': phone,
      'email': email,
      'gender': gender,
      'birthDate': birthDate,
      'teachingExperience': teachingExperience,
      'role': role,
      'badge': badge,
      'isVerified': isVerified,
      'createTime': createTime.toIso8601String(),
      'points': points,
    };
  }
}

class UserStatistics {
  final int orderCount;
  final int favoriteCount;
  final int reviewCount;

  UserStatistics({
    required this.orderCount,
    required this.favoriteCount,
    required this.reviewCount,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      orderCount: json['orderCount'] is int ? json['orderCount'] : int.tryParse(json['orderCount']?.toString() ?? '0') ?? 0,
      favoriteCount: json['favoriteCount'] is int ? json['favoriteCount'] : int.tryParse(json['favoriteCount']?.toString() ?? '0') ?? 0,
      reviewCount: json['reviewCount'] is int ? json['reviewCount'] : int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
    );
  }
}
