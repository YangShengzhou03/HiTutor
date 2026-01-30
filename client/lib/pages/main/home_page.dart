import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/tutor_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/tutor_model.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
import '../student_request/student_request_detail_page.dart';
import '../tutor_service/tutor_service_detail_page.dart';
import '../notification/notification_page.dart';

final BorderRadius _borderRadius12 = BorderRadius.circular(12);
final BorderRadius _borderRadius14 = BorderRadius.circular(14);
const EdgeInsets _padding16 = EdgeInsets.all(16);
const EdgeInsets _paddingH16V12 = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 12,
);
const EdgeInsets _paddingH14V4 = EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 4,
);
const EdgeInsets _paddingH8V4 = EdgeInsets.symmetric(
  horizontal: 8,
  vertical: 4,
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;
  bool _isSearching = false;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDataBasedOnRole();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final response = await ApiService.getUnreadNotificationCount();
      if (response is Map && response['success'] == true) {
        setState(() {
          _unreadNotificationCount = response['data'] ?? 0;
        });
      }
    } catch (_) {
    }
  }

  void _loadDataBasedOnRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tutorProvider = Provider.of<TutorProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null && user.userRole == 'tutor') {
      tutorProvider.getNearbyStudents();
    } else {
      tutorProvider.getNearbyTutors();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _handleSearch(String query) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        if (user != null && user.userRole == 'tutor') {
          Provider.of<TutorProvider>(context, listen: false).searchStudents(query);
        } else {
          Provider.of<TutorProvider>(context, listen: false).searchTutors(query);
        }
        setState(() {
          _isSearching = query.isNotEmpty;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<TutorProvider>(context, listen: false).resetSearch();
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final contentPadding = isTablet
        ? EdgeInsets.symmetric(horizontal: screenWidth * 0.15)
        : _padding16;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final userRole = user?.userRole ?? 'student';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(userRole),
            Expanded(
              child: Consumer<TutorProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.tutors.isEmpty && !_isSearching) {
                    return _buildLoadingState(userRole);
                  }

                  if (provider.errorMessage.isNotEmpty && !_isSearching) {
                    return _buildErrorState(provider.errorMessage);
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: contentPadding,
                      child: Column(
                        children: [
                          _buildQuickActions(userRole),
                          if (_isSearching)
                            _buildSearchResults(provider, userRole)
                          else
                            _buildListings(provider, userRole),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(String role) {
    final hintText = role == 'tutor' ? '搜索学生需求、科目...' : '搜索家教、科目、地区...';
    
    return Container(
      padding: _paddingH16V12,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: Container(
                padding: _paddingH14V4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _borderRadius12,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _handleSearch,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: hintText,
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textTertiary.withOpacity(0.6),
                          ),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                        cursorColor: AppTheme.primaryColor,
                        enableInteractiveSelection: false,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: _clearSearch,
                        child: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              ).then((_) {
                _loadUnreadNotificationCount();
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: _borderRadius12,
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (_unreadNotificationCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final user = authProvider.user;
              final role = user?.userRole ?? 'student';
              Navigator.pushNamed(context, Routes.map, arguments: role);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: _borderRadius12,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(String role) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            Icons.school_rounded,
            '附近学生',
            AppTheme.primaryColor,
            () => Navigator.pushNamed(context, Routes.map, arguments: 'tutor'),
          ),
          _buildQuickActionItem(
            Icons.person_search_rounded,
            '附近老师',
            const Color(0xFF722ED1),
            () => Navigator.pushNamed(context, Routes.map, arguments: 'student'),
          ),
          _buildQuickActionItem(
            Icons.edit_document,
            '我要发布',
            const Color(0xFF10B981),
            () {
              if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
                Navigator.pushNamed(
                  context,
                  role == 'tutor' ? Routes.publishTutorService : Routes.publishStudentRequest,
                );
              } else {
                Navigator.pushNamed(context, Routes.smsLogin);
              }
            },
          ),
          _buildQuickActionItem(
            Icons.monetization_on_rounded,
            '我的积分',
            const Color(0xFFFF9500),
            () {
              if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
                Navigator.pushNamed(context, Routes.points);
              } else {
                Navigator.pushNamed(context, Routes.smsLogin);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: _borderRadius12,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String role) {
    final message = role == 'tutor' ? '正在加载附近学生...' : '正在加载附近家教...';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          const Text(
            '加载失败',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _loadDataBasedOnRole();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListings(TutorProvider provider, String role) {
    final title = role == 'tutor' ? '附近学生' : '附近家教';
    final emptyMessage = role == 'tutor' ? '暂无附近学生' : '暂无附近家教';
    
    if (provider.tutors.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                '查看更多',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.tutors.map(
            (tutor) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCard(tutor, role),
            ),
          ),
          if (provider.hasMore && !provider.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    provider.loadMore(role);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('加载更多'),
                ),
              ),
            ),
          if (provider.isLoading && provider.tutors.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(TutorProvider provider, String role) {
    if (provider.isSearching) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = role == 'tutor' ? '搜索结果' : '搜索结果';
    final emptyMessage = role == 'tutor' ? '未找到相关学生' : '未找到相关家教';
    
    if (provider.searchResults.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: _buildEmptyState(emptyMessage),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${provider.searchResults.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...provider.searchResults.map(
            (tutor) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCard(tutor, role),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Tutor tutor, String role) {
    final bool isVerified = tutor.user.isVerified ?? false;

    Color accentColor;
    final subjectName = tutor.subjects.firstOrNull?.name.toLowerCase() ?? '';
    if (subjectName.contains('数学') || subjectName.contains('math')) {
      accentColor = AppTheme.primaryColor;
    } else if (subjectName.contains('英语') || subjectName.contains('english')) {
      accentColor = const Color(0xFF10B981);
    } else if (subjectName.contains('物理') || subjectName.contains('physics')) {
      accentColor = const Color(0xFFF59E0B);
    } else if (subjectName.contains('化学') ||
        subjectName.contains('chemistry')) {
      accentColor = const Color(0xFFEF4444);
    } else if (subjectName.contains('生物') || subjectName.contains('biology')) {
      accentColor = const Color(0xFF14B8A6);
    } else {
      accentColor = AppTheme.primaryColor;
    }

    List<String> tags = [];
    if (tutor.educationBackground.contains('985') ||
        tutor.educationBackground.contains('211')) {
      tags.add('名校毕业');
    }
    if (tutor.rating > 4.8) {
      tags.add('评分高');
    }
    if (tags.isEmpty) {
      tags.add('认真负责');
    }

    String subtitle = '';
    final gradeLevels = tutor.targetGradeLevels.map((g) => g.displayName).join('、');
    if (gradeLevels.isNotEmpty) {
      subtitle += gradeLevels;
      if (subtitle.isNotEmpty) subtitle += ' · ';
    }
    subtitle += tutor.subjects.map((s) => s.name).join('、');

    return GestureDetector(
      onTap: () {
        if (tutor.type == 'student_request') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentRequestDetailPage(request: tutor),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorServiceDetailPage(tutor: tutor),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: _borderRadius14,
          border: Border.all(color: AppTheme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: _borderRadius12,
              ),
              child: Center(
                child: Text(
                  tutor.user.username.isNotEmpty ? tutor.user.username[0] : 'U',
                  style: TextStyle(
                    fontSize: 24,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                _truncateName(tutor.user.username),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified == true)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified, size: 8, color: Colors.blue.shade700),
                                      const SizedBox(width: 2),
                                      Text(
                                        '已认证',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (tutor.user.badge != null && tutor.user.badge!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF2F8),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    tutor.user.badge!,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFFEC4899),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (tutor.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tutor.rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (tutor.user.gender != null && tutor.user.gender!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            (tutor.user.gender!.toLowerCase() == 'male' || tutor.user.gender == '男') ? '♂' : '♀',
                            style: TextStyle(
                              fontSize: 13,
                              color: (tutor.user.gender!.toLowerCase() == 'male' || tutor.user.gender == '男') ? AppTheme.maleColor : AppTheme.femaleColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...tags.map(
                        (tag) => Padding(
                          padding: EdgeInsets.only(
                            right: tags.indexOf(tag) < tags.length - 1 ? 5 : 0,
                          ),
                          child: Container(
                            padding: _paddingH8V4,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '¥${tutor.pricePerHour}/小时',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateName(String name) {
    if (name.length > 6) {
      return '${name.substring(0, 6)}...';
    }
    return name;
  }
}