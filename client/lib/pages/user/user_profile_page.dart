import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/tutor_model.dart';

import '../tutor_service/tutor_service_detail_page.dart';
import '../student_request/student_request_detail_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String userName;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<dynamic> _userServices = [];
  List<dynamic> _userRequests = [];
  String _errorMessage = '';

  static const _padding16 = EdgeInsets.all(16);
  static const _padding12 = EdgeInsets.all(12);
  static final _borderRadius12 = BorderRadius.circular(12);
  static final _borderRadius16 = BorderRadius.circular(16);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final userResponse = await ApiService.getUser(widget.userId, needAuth: false);
      Map<String, dynamic>? userData;
      List<dynamic> userServices = [];
      List<dynamic> userRequests = [];
      
      if (userResponse['success'] == true) {
        userData = userResponse['data'];
      }

      final isOwnProfile = authProvider.user?.id == widget.userId;
      
      try {
        if (isOwnProfile) {
          final servicesResponse = await ApiService.getUserServicesWithUserId(widget.userId);
          if (servicesResponse['success'] == true) {
            userServices = servicesResponse['data']?['content'] ?? [];
          }

          final requestsResponse = await ApiService.getUserRequestsWithUserId(widget.userId);
          if (requestsResponse['success'] == true) {
            userRequests = requestsResponse['data']?['content'] ?? [];
          }
        } else {
          final servicesResponse = await ApiService.getUserServicesByUserId(widget.userId, needAuth: false);
          if (servicesResponse['success'] == true) {
            userServices = servicesResponse['data']?['content'] ?? [];
          }

          final requestsResponse = await ApiService.getUserRequestsByUserId(widget.userId, needAuth: false);
          if (requestsResponse['success'] == true) {
            userRequests = requestsResponse['data']?['content'] ?? [];
          }
        }
      } catch (e) {
        // 静默处理错误，因为这不是关键数据
      }

      if (!mounted) return;
      
      setState(() {
        _userData = userData;
        _userServices = userServices;
        _userRequests = userRequests;
        // 从第一个家教服务中获取教育背景信息
        if (userServices.isNotEmpty && userData != null) {
          final firstService = userServices[0];
          userData['education'] = firstService['education'] ?? '';
          userData['school'] = firstService['school'] ?? '';
          userData['major'] = firstService['major'] ?? '';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('聊天功能开发中')),
    );
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwnProfile = authProvider.user?.id == widget.userId;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('${widget.userName}的主页'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textPrimary,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
        actions: !isOwnProfile ? [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能开发中')),
              );
            },
            color: AppTheme.textSecondary,
          ),
        ] : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwnProfile = authProvider.user?.id == widget.userId;
    
    return ListView(
      padding: _padding12,
      children: [
        _buildUserInfo(),
        const SizedBox(height: 16),
        _buildUserStatistics(),
        const SizedBox(height: 16),
        if (!isOwnProfile) ...[
          _buildActionButtons(),
          const SizedBox(height: 16),
        ],
        _buildEducationSection(),
        const SizedBox(height: 16),
        if (_userServices.isNotEmpty) _buildUserServices(),
        if (_userServices.isNotEmpty) const SizedBox(height: 16),
        if (_userRequests.isNotEmpty) _buildUserRequests(),
        if (_userRequests.isNotEmpty) const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUserInfo() {
    if (_userData == null) {
      return const SizedBox.shrink();
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwnProfile = authProvider.user?.id == widget.userId;
    
    final name = _userData?['name']?.toString() ?? widget.userName;

    final badge = _userData?['badge']?.toString();
    final isVerified = _parseBool(_userData?['isVerified']);
    final gender = _userData?['gender']?.toString();
    final role = _userData?['role']?.toString() ?? 'student';
    final initial = name.isNotEmpty ? name[0] : 'U';
    final phone = _userData?['phone']?.toString() ?? '';

    return Container(
      padding: _padding16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _borderRadius16,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4),
                        if (gender != null && gender.isNotEmpty)
                          Text(
                            gender == 'male' ? '♂' : '♀',
                            style: TextStyle(
                              fontSize: 16,
                              color: gender == 'male' ? AppTheme.maleColor : AppTheme.femaleColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(width: 4),
                        if (isVerified == true) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade200, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '已认证',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        if (badge != null && badge.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF2F8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFEC4899),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          role == 'tutor' ? '家教' : '学生',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (isOwnProfile && phone.isNotEmpty)
                          const SizedBox(width: 8),
                        if (isOwnProfile && phone.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 12,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),  
        ],
      ),
    );
  }

  Widget _buildEducationCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }



  Widget _buildUserStatistics() {
    if (_userData == null) {
      return const SizedBox.shrink();
    }

    final reviews = _userData?['reviewCount']?.toString() ?? '0';
    final rating = _userData?['rating']?.toString() ?? '0.0';
    final points = _userData?['points']?.toString() ?? '0';

    return Container(
      padding: _padding16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _borderRadius16,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '统计信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('评分', '$rating分'),
              _buildStatItem('评价', '$reviews条'),
              _buildStatItem('积分', '$points分'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       const Text(
          '发布的服务',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._userServices.take(3).map((service) => _buildServiceCard(service)),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final subject = service['subjectName']?.toString() ?? '';
    final price = service['hourlyRate']?.toString() ?? '0';
    final description = service['description']?.toString() ?? '';
    final tutor = Tutor.fromJson(service);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorServiceDetailPage(tutor: tutor),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: _padding12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _borderRadius12,
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '¥$price/小时',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '发布的需求',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._userRequests.take(3).map((request) => _buildRequestCard(request)),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final subject = request['subjectName']?.toString() ?? '';
    final price = request['hourlyRateMin']?.toString() ?? '0';
    final requirements = request['requirements']?.toString() ?? '';
    final tutor = Tutor.fromJson(request);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentRequestDetailPage(request: tutor),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: _padding12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _borderRadius12,
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    requirements,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '¥$price/小时',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwnProfile = authProvider.user?.id == widget.userId;

    if (isOwnProfile) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: _padding16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _borderRadius16,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _startChat,
          icon: const Icon(Icons.chat_rounded, size: 18),
          label: const Text('联系TA'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    if (_userData == null) {
      return const SizedBox.shrink();
    }

    final education = _userData?['education']?.toString() ?? '';
    final school = _userData?['school']?.toString() ?? '';
    final major = _userData?['major']?.toString() ?? '';

    if (education.isEmpty && school.isEmpty && major.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: _padding16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _borderRadius16,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '教育背景',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEducationCard(
                  Icons.school_outlined,
                  '学历',
                  education.isNotEmpty ? education : '暂无信息',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEducationCard(
                  Icons.account_balance_outlined,
                  '院校',
                  school.isNotEmpty ? school : '暂无信息',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEducationCard(
            Icons.menu_book_outlined,
            '专业',
            major.isNotEmpty ? major : '暂无信息',
          ),
        ],
      ),
    );
  }
}
