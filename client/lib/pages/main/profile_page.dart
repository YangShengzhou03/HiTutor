import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';
import '../../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _orderCount = 0;
  int _publishingCount = 0;
  int _favoriteCount = 0;
  int _pointsCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  static const _padding12 = EdgeInsets.all(12);
  static const _padding14 = EdgeInsets.all(14);
  static const _padding16 = EdgeInsets.all(16);
  static const _padding20 = EdgeInsets.all(20);
  static const _padding10 = EdgeInsets.all(10);
  static const _paddingH8V2 = EdgeInsets.symmetric(horizontal: 8, vertical: 2);
  static final _borderRadius4 = BorderRadius.circular(4);
  static final _borderRadius10 = BorderRadius.circular(10);
  static final _borderRadius12 = BorderRadius.circular(12);
  static final _borderRadius16 = BorderRadius.circular(16);
  static final _borderRadius32 = BorderRadius.circular(32);

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        try {
          final ordersResponse = await ApiService.getUserOrders(userId.toString());
          if (ordersResponse['success'] == true) {
            final orders = ordersResponse['data'] ?? [];
            _orderCount = orders.length;
          }
        } catch (_) {
        }

        try {
          _publishingCount = 0;
          final requestsResponse = await ApiService.getUserRequests();
          if (requestsResponse['success'] == true) {
            final requests = requestsResponse['data']?['content'] ?? [];
            _publishingCount += (requests.length as num).toInt();
          }

          final servicesResponse = await ApiService.getUserServices();
          if (servicesResponse['success'] == true) {
            final services = servicesResponse['data']?['content'] ?? [];
            _publishingCount += (services.length as num).toInt();
          }
        } catch (_) {
        }

        try {
          final favoritesResponse = await ApiService.getFavorites(userId);
          if (favoritesResponse['success'] == true) {
            final favorites = favoritesResponse['data'] ?? [];
            _favoriteCount = favorites.length;
          }
        } catch (_) {
        }

        try {
          final pointsResponse = await ApiService.getTotalPoints(userId);
          if (pointsResponse['success'] == true) {
            final data = pointsResponse['data'];
            if (data is Map && data.containsKey('totalPoints')) {
              _pointsCount = data['totalPoints'] ?? 0;
            } else {
              _pointsCount = data ?? 0;
            }
          }
        } catch (_) {
        }
      }
    } catch (_) {
      setState(() {
        _errorMessage = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _reloadData() {
    _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return _buildContent(context, authProvider);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthProvider authProvider) {
    return ListView(
      padding: _padding12,
      children: [
        _buildUserInfo(context, authProvider),
        const SizedBox(height: 16),
        _buildStatistics(context),
        const SizedBox(height: 16),
        _buildQuickActions(context, authProvider),
        const SizedBox(height: 16),
        _buildTutorServices(context, authProvider),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
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
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _reloadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: _borderRadius10,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatisticItem(_orderCount.toString(), '家教预约', context),
                    _buildStatisticItem(_publishingCount.toString(), '我的发布', context),
                    _buildStatisticItem(_favoriteCount.toString(), '收藏家教', context),
                    _buildStatisticItem(_pointsCount.toString(), '我的积分', context),
                  ],
                ),
    );
  }

  Widget _buildUserInfo(BuildContext context, AuthProvider authProvider) {
    
    if (!authProvider.isAuthenticated) {
      return Container(
        padding: _padding20,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '请登录以查看个人信息',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                
                Navigator.pushNamed(context, Routes.smsLogin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: _borderRadius10,
                ),
              ),
              child: const Text('登录'),
            ),
          ],
        ),
      );
    }

    
    final user = authProvider.user;
    

    
    if (user == null) {
      return Container(
        padding: _padding20,
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
        child: const Center(
          child: Text(
            '加载中...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }
    
    
    final initial = user.name.isNotEmpty ? user.name[0] : 'U';
    
    
    String userLabel = '';
    if (user.role == 'tutor') {
      userLabel = '家教';
    } else if (user.role == 'student') {
      userLabel = '学生';
    }

    return Container(
      padding: _padding20,
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
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.profileEdit),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: _borderRadius32,
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: _paddingH8V2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: _borderRadius4,
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
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  userLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.settings),
            child: Container(
              padding: _padding10,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: _borderRadius10,
              ),
              child: const Icon(
                Icons.settings_rounded,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String count, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case '家教预约':
            Navigator.pushNamed(context, Routes.appointment);
            break;
          case '我的发布':
            Navigator.pushNamed(context, Routes.myPublishings);
            break;
          case '收藏家教':
            Navigator.pushNamed(context, Routes.favorites);
            break;
          case '我的积分':
            Navigator.pushNamed(context, Routes.points);
            break;
        }
      },
      child: Column(
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
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthProvider authProvider) {
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
        children: [
          Expanded(
            child: _buildQuickActionCard(
              context,
              Icons.person_search_rounded,
              '请家教',
              '发布家教需求',
              AppTheme.primaryColor,
              () => Navigator.pushNamed(context, Routes.publishStudentRequest),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              context,
              Icons.work_rounded,
              '做家教',
              '发布家教信息',
              const Color(0xFF10B981),
              () => Navigator.pushNamed(context, Routes.publishTutorService),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: _padding14,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: _borderRadius12,
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: _borderRadius12,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorServices(BuildContext context, AuthProvider authProvider) {
    
    if (!authProvider.isAuthenticated) {
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
        child: const Center(
          child: Text(
            '请登录以查看家教信息',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
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
            '家教信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildServiceGrid(context, [
            ['我的预约', Icons.calendar_today_rounded, const Color(0xFF10B981)],
            ['我的报名', Icons.assignment_turned_in_rounded, const Color(0xFF8B5CF6)],
            ['我的收藏', Icons.favorite_rounded, const Color(0xFFF59E0B)],
            ['我的评价', Icons.star_rounded, const Color(0xFF722ED1)],
            ['家教简历', Icons.description_rounded, const Color(0xFF6366F1)],
            ['家教认证', Icons.verified_rounded, const Color(0xFFEC4899)],
            ['联系客服', Icons.headset_mic_rounded, AppTheme.primaryColor],
            ['我的举报', Icons.report_rounded, const Color(0xFFEF4444)],
          ]),
        ],
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context, List<List<dynamic>> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) => _buildServiceItem(
        context,
        services[index][0] as String,
        services[index][1] as IconData,
        services[index][2] as Color,
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    void handleServiceTap() {
      switch (title) {
        case '联系客服':
          Navigator.pushNamed(context, Routes.customerService);
          break;
        case '我的预约':
          Navigator.pushNamed(context, Routes.appointment);
          break;
        case '我的收藏':
          Navigator.pushNamed(context, Routes.favorites);
          break;
        case '我的评价':
          Navigator.pushNamed(context, Routes.myReviews);
          break;
        case '我的举报':
          Navigator.pushNamed(context, Routes.complaintList);
          break;
        case '家教认证':
          Navigator.pushNamed(context, Routes.tutorCertification);
          break;
        case '家教简历':
          Navigator.pushNamed(context, Routes.tutorResume);
          break;
        case '我的报名':
          Navigator.pushNamed(context, Routes.myApplications);
          break;
        default:
          break;
      }
    }

    return GestureDetector(
      onTap: handleServiceTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: _borderRadius10,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}