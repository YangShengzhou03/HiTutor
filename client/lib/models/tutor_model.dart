import 'user_model.dart';

class Tutor {
  final String id;
  final User user;
  final List<Subject> subjects;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final String pricePerHour;
  final String experience;
  final String educationBackground;
  final String description;
  final String? address;
  final List<String> certifications;
  final bool isAvailable;
  final DateTime createdAt;
  final String type;
  final List<GradeLevel> targetGradeLevels;
  final String? latitude;
  final String? longitude;

  Tutor({
    required this.id,
    required this.user,
    required this.subjects,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.experience,
    required this.educationBackground,
    required this.description,
    this.address,
    required this.certifications,
    required this.isAvailable,
    required this.createdAt,
    required this.type,
    required this.targetGradeLevels,
    this.latitude,
    this.longitude,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    final user = json.containsKey('user') ? User.fromJson(json['user']) : 
                 json.containsKey('tutor') ? User.fromJson(json['tutor']) : 
                 User(
                   id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
                   name: json['userName']?.toString() ?? json['name']?.toString() ?? '',
                   username: json['userName']?.toString(),
                   avatar: json['userAvatar']?.toString() ?? json['avatar']?.toString() ?? '',
                   phone: '',
                   email: '',
                   isVerified: json['userVerified'] == true || json['userVerified'] == 1,
                   createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
                 );
    
    List<GradeLevel> gradeLevels = [];
    if (json['targetGradeLevels'] != null) {
      if (json['targetGradeLevels'] is List) {
        gradeLevels = (json['targetGradeLevels'] as List)
            .map((e) => GradeLevel.fromJson(e))
            .toList();
      } else if (json['targetGradeLevels'] is String) {
        final gradeLevelsStr = json['targetGradeLevels'].toString();
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
    } else if (json['gradeLevels'] != null) {
      if (json['gradeLevels'] is List) {
        gradeLevels = (json['gradeLevels'] as List)
            .map((e) => GradeLevel.fromJson(e))
            .toList();
      } else if (json['gradeLevels'] is String) {
        final gradeLevelsStr = json['gradeLevels'].toString();
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
    } else if (json['childGrade'] != null) {
      final childGrade = json['childGrade'];
      if (childGrade != null && childGrade.toString().isNotEmpty) {
        gradeLevels = [
          GradeLevel(
            id: childGrade.toString(),
            name: childGrade.toString(),
            displayName: childGrade.toString(),
          ),
        ];
      }
    }
    
    return Tutor(
      id: json['id']?.toString() ?? '',
      user: user,
      subjects: json['subjectName'] != null 
          ? [Subject(id: '', name: json['subjectName'], icon: '')]
          : [],
      tags: [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      pricePerHour: json['hourlyRate']?.toString() ?? json['pricePerHour'] ?? (json['hourlyRateMin'] != null || json['hourlyRateMax'] != null ? '${json['hourlyRateMin'] ?? 0}-${json['hourlyRateMax'] ?? 0}' : '0'),
      experience: user.teachingExperienceText,
      educationBackground: user.education ?? '',
      description: json['description'] ?? '',
      address: json['address'],
      certifications: [],
      isAvailable: json['status'] == 'available' || json['status'] == 'active' || json['isAvailable'] == true,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      type: json['type'] ?? 'tutor_service',
      targetGradeLevels: gradeLevels,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

class Subject {
  final String id;
  final String name;
  final String icon;

  Subject({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }

  static final List<Subject> popularSubjects = [
    Subject(
      id: 'math',
      name: '数学',
      icon: 'calculate',
    ),
    Subject(
      id: 'english',
      name: '英语',
      icon: 'translate',
    ),
    Subject(
      id: 'physics',
      name: '物理',
      icon: 'science',
    ),
    Subject(
      id: 'chemistry',
      name: '化学',
      icon: 'biotech',
    ),
    Subject(
      id: 'chinese',
      name: '语文',
      icon: 'menu_book',
    ),
    Subject(
      id: 'history',
      name: '历史',
      icon: 'history_edu',
    ),
    Subject(
      id: 'geography',
      name: '地理',
      icon: 'public',
    ),
    Subject(
      id: 'music',
      name: '音乐',
      icon: 'music_note',
    ),
  ];
}

class GradeLevel {
  final String id;
  final String name;
  final String displayName;

  GradeLevel({
    required this.id,
    required this.name,
    required this.displayName,
  });

  factory GradeLevel.fromJson(Map<String, dynamic> json) {
    return GradeLevel(
      id: json['id']?.toString() ?? json['name'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
    };
  }

  static final List<GradeLevel> allGradeLevels = [
    GradeLevel(
      id: 'preschool',
      name: 'preschool',
      displayName: '学前',
    ),
    GradeLevel(
      id: 'primary',
      name: 'primary',
      displayName: '小学',
    ),
    GradeLevel(
      id: 'junior_high',
      name: 'junior_high',
      displayName: '初中',
    ),
    GradeLevel(
      id: 'senior_high',
      name: 'senior_high',
      displayName: '高中',
    ),
  ];
}

class Review {
  final String id;
  final User reviewer;
  final String content;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewer,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('reviewerName')) {
      return Review(
        id: json['id']?.toString() ?? '',
        reviewer: User(
          id: json['reviewerId']?.toString() ?? '',
          name: json['reviewerName'] ?? '匿名用户',
          avatar: json['reviewerAvatar'] ?? '',
          phone: '',
          email: '',
          isVerified: false,
          createdAt: DateTime.now(),
        ),
        content: json['comment'] ?? '',
        rating: (json['rating'] ?? 0).toDouble(),
        createdAt: json['createdAt'] != null 
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
      );
    }

    return Review(
      id: json['id']?.toString() ?? '',
      reviewer: User.fromJson(json['reviewer'] ?? {}),
      content: json['content'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class TeachingExperience {
  final String id;
  final String schoolName;
  final String position;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;

  TeachingExperience({
    required this.id,
    required this.schoolName,
    required this.position,
    required this.description,
    required this.startDate,
    this.endDate,
  });

  factory TeachingExperience.fromJson(Map<String, dynamic> json) {
    return TeachingExperience(
      id: json['id'],
      schoolName: json['schoolName'],
      position: json['position'],
      description: json['description'],
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}
