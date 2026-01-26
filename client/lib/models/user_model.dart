class User {
  final String id;
  final String name;
  final String? username;
  final String avatar;
  final String phone;
  final String email;
  final String? gender;
  final String? birthDate;
  final String? education;
  final String? school;
  final String? major;
  final int? teachingExperience;
  final bool isVerified;
  final String? role;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final int? points;

  User({
    required this.id,
    required this.name,
    this.username,
    required this.avatar,
    required this.phone,
    required this.email,
    this.gender,
    this.birthDate,
    this.education,
    this.school,
    this.major,
    this.teachingExperience,
    required this.isVerified,
    this.role,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.points,
  });

  
  String get userRole => role ?? 'student';

  
  String get teachingExperienceText => teachingExperience != null ? '$teachingExperience年' : '';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId']?.toString() ?? json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['userName']?.toString() ?? '',
      username: json['username']?.toString(),
      avatar: json['avatar']?.toString() ?? json['userAvatar']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString(),
      birthDate: json['birthDate']?.toString(),
      education: json['education']?.toString(),
      school: json['school']?.toString(),
      major: json['major']?.toString(),
      teachingExperience: json['teachingExperience'] is int ? json['teachingExperience'] : null,
      isVerified: json['isVerified'] == true || json['isVerified'] == 1 || json['userVerified'] == true || json['userVerified'] == 1,
      role: json['role']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      latitude: json['latitude'] is num ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] is num ? json['longitude'].toDouble() : null,
      points: json['points'] is int ? json['points'] : null,
    );
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
      'name': name,
      'username': username,
      'avatar': avatar,
      'phone': phone,
      'email': email,
      'education': education,
      'school': school,
      'major': major,
      'gender': gender,
      'birthDate': birthDate,
      'teachingExperience': teachingExperience,
      'isVerified': isVerified,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
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
