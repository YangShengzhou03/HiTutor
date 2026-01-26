import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';
import '../../models/tutor_model.dart';
import '../../routes.dart';
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
  bool _isBlocked = false;

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
      
      if (authProvider.isAuthenticated && authProvider.user?.id != widget.userId) {
        try {
          final blockedResponse = await ApiService.checkBlocked(widget.userId);
          if (blockedResponse['success'] == true) {
            _isBlocked = blockedResponse['data'] ?? false;
          }
        } catch (e) {
        }
      }

      final userResponse = await ApiService.getUser(widget.userId, needAuth: false);
      if (userResponse['success'] == true) {
        setState(() {
          _userData = userResponse['data'];
        });
      }

      final isOwnProfile = authProvider.user?.id == widget.userId;
      
      try {
        if (isOwnProfile) {
          final servicesResponse = await ApiService.getUserServices();
          if (servicesResponse['success'] == true) {
            final content = servicesResponse['data']?['content'] ?? [];
            setState(() {
              _userServices = content;
            });
          }

          final requestsResponse = await ApiService.getUserRequests();
          if (requestsResponse['success'] == true) {
            final content = requestsResponse['data']?['content'] ?? [];
            setState(() {
              _userRequests = content;
            });
          }
        } else {
          final servicesResponse = await ApiService.getUserServicesByUserId(widget.userId, needAuth: false);
          if (servicesResponse['success'] == true) {
            final content = servicesResponse['data']?['content'] ?? [];
            setState(() {
              _userServices = content;
            });
          }

          final requestsResponse = await ApiService.getUserRequestsByUserId(widget.userId, needAuth: false);
          if (requestsResponse['success'] == true) {
            final content = requestsResponse['data']?['content'] ?? [];
            setState(() {
              _userRequests = content;
            });
          }
        }
      } catch (e) {
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startChat() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请先登录')),
          );
        }
        return;
      }
      
      final response = await ApiService.createConversation(userId, widget.userId);
      if (response['success'] == true) {
        final conversationId = response['data']['id']?.toString() ?? '';
        if (mounted && conversationId.isNotEmpty) {
          Navigator.pushNamed(
            context,
            Routes.chatDetail,
            arguments: {
              'conversationId': conversationId,
              'otherUserId': widget.userId,
              'otherUserName': widget.userName,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动聊天失败: $e')),
        );
      }
    }
  }

  Future<void> _toggleBlock() async {
    try {
      if (_isBlocked) {
        await ApiService.removeFromBlacklist(widget.userId);
        setState(() {
          _isBlocked = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已从黑名单移除')),
          );
        }
      } else {
        await ApiService.addToBlacklist(widget.userId);
        setState(() {
          _isBlocked = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已添加到黑名单')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onSelected: (value) {
              if (value == 'block') {
                _toggleBlock();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(
                      _isBlocked ? Icons.block : Icons.block,
                      color: _isBlocked ? AppTheme.textSecondary : AppTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(_isBlocked ? '解除拉黑' : '拉黑'),
                  ],
                ),
              ),
            ],
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
    return ListView(
      padding: _padding12,
      children: [
        _buildUserInfo(),
        const SizedBox(height: 16),
        _buildUserStatistics(),
        const SizedBox(height: 16),
        if (_userServices.isNotEmpty) _buildUserServices(),
        if (_userServices.isNotEmpty) const SizedBox(height: 16),
        if (_userRequests.isNotEmpty) _buildUserRequests(),
        if (_userRequests.isNotEmpty) const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildUserInfo() {
    if (_userData == null) {
      return const SizedBox.shrink();
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwnProfile = authProvider.user?.id == widget.userId;
    
    final name = _userData?['username']?.toString() ?? widget.userName;
    final role = _userData?['role']?.toString() ?? 'student';
    final isVerified = _userData?['isVerified'] == true || _userData?['isVerified'] == 1;
    final initial = name.isNotEmpty ? name[0] : 'U';
    final education = _userData?['education']?.toString() ?? '';
    final phone = _userData?['phone']?.toString() ?? '';
    final email = _userData?['email']?.toString() ?? '';
    final teachingExperience = _userData?['teachingExperience']?.toString() ?? '';
    final school = _userData?['school']?.toString() ?? '';
    final major = _userData?['major']?.toString() ?? '';

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
                        if (isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: Color(0xFF0EA5E9),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '已认证',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF0EA5E9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role == 'tutor' ? '家教' : '学生',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              if (education.isNotEmpty) _buildInfoChip('教育背景', education, Icons.school),
              if (school.isNotEmpty) _buildInfoChip('学校', school, Icons.location_city),
              if (major.isNotEmpty) _buildInfoChip('专业', major, Icons.menu_book),
              if (teachingExperience.isNotEmpty) _buildInfoChip('教学经验', '$teachingExperience年', Icons.work_history),
              if (isOwnProfile && phone.isNotEmpty) _buildInfoChip('手机号', phone, Icons.phone),
              if (email.isNotEmpty) _buildInfoChip('邮箱', email, Icons.email),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatistics() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatisticItem(_userServices.length.toString(), '发布服务'),
          _buildStatisticItem(_userRequests.length.toString(), '发布需求'),
          _buildStatisticItem('0', '完成预约'),
          _buildStatisticItem('0', '获得评价'),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
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
}
