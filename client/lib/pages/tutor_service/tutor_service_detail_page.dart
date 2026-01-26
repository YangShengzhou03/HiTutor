import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/tutor_model.dart';
import '../application/application_form_page.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../about/complaint_page.dart';
import '../../routes.dart';
import '../../utils/error_handler.dart';

class TutorServiceDetailPage extends StatefulWidget {
  final Tutor tutor;

  const TutorServiceDetailPage({super.key, required this.tutor});

  @override
  State<TutorServiceDetailPage> createState() => _TutorServiceDetailPageState();
}

class _TutorServiceDetailPageState extends State<TutorServiceDetailPage> {
  bool _isFavorite = false;
  bool _isLoadingReviews = false;
  List<Review> _reviews = [];
  bool _hasBooked = false;
  bool _isOwnService = false;
  Tutor? _updatedTutor;

  Tutor get _currentTutor => _updatedTutor ?? widget.tutor;

  @override
  void initState() {
    super.initState();
    _loadTutorDetail().then((_) {
      _loadReviews();
      _checkBookingStatus();
      _loadFavoriteStatus();
      _checkOwnership();
    });
  }

  Future<void> _loadTutorDetail() async {
    try {
      final response = await ApiService.getService(widget.tutor.id);
      if (response is Map && response['success'] == true) {
        final data = response['data'];
        if (data is Map) {
          setState(() {
            _updatedTutor = Tutor.fromJson(Map<String, dynamic>.from(data));
          });
        }
      }
    } catch (_) {
    }
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      
      if (userId == null) {
        return;
      }

      final response = await ApiService.getFavorites(userId);
      final favorites = response is List ? response : (response['data'] ?? []);
      
      if (favorites is List) {
        final tutorIdLong = int.tryParse(widget.tutor.id);
        final isFavorite = favorites.any((item) {
          if (item is Map) {
            final targetType = item['targetType'];
            final targetId = item['targetId'];
            return (targetType == 'tutor' || targetType == 'tutor_profile') && 
                   targetId == tutorIdLong;
          }
          return false;
        });

        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (_) {
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    try {
      if (_isFavorite) {
        await ApiService.removeFavorite(userId, widget.tutor.id, 'tutor_profile');
      } else {
        final targetIdLong = int.tryParse(widget.tutor.id);
        if (targetIdLong == null) {
          throw Exception('无效的家教ID');
        }
        await ApiService.addFavorite({
          'userId': userId,
          'targetType': 'tutor_profile',
          'targetId': targetIdLong,
        });
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, e);
    }
  }

  Future<void> _checkBookingStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        final applications = await ApiService.getApplicationsByApplicantId(userId);
        if (applications['success'] == true) {
          final data = applications['data'] ?? [];
          if (data is List) {
            final tutorId = int.tryParse(widget.tutor.id);
            _hasBooked = data.any((app) {
              final requestId = app['requestId'];
              final requestType = app['requestType'];
              return requestId == tutorId && requestType == 'tutor_profile';
            });
          }
        }
      }
    } catch (_) {
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final response = await ApiService.getReviews(widget.tutor.id);
      List reviewsData = [];
      if (response is List) {
        reviewsData = response;
      } else if (response is Map) {
        reviewsData = (response['data'] ?? response['content'] ?? []) as List;
      }
      _reviews = reviewsData.map((item) => Review.fromJson(item)).toList();
    } catch (_) {
    } finally {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  void _checkOwnership() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    
    if (userId != null) {
      setState(() {
        _isOwnService = _currentTutor.user.id.toString() == userId.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getSubjectColor(_currentTutor.subjects.firstOrNull?.name ?? '');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textPrimary,
        ),
        title: const Text(
          '家教信息详情',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : AppTheme.textSecondary,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.report_outlined),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final currentUserId = authProvider.user?.id;
              
              if (currentUserId == _currentTutor.user.id) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('自己不能举报自己哦')),
                );
                return;
              }
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComplaintPage(
                    targetUserId: _currentTutor.user.id,
                  ),
                ),
              );
            },
            color: AppTheme.textSecondary,
            tooltip: '举报',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能还在开发中')),
              );
            },
            color: AppTheme.textSecondary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(accentColor),
            const SizedBox(height: 16),
            _buildBasicInfoSection(accentColor),
            const SizedBox(height: 16),
            _buildEducationSection(),
            const SizedBox(height: 16),
            _buildTeachingSection(),
            const SizedBox(height: 16),
            _buildIntroductionSection(),
            const SizedBox(height: 16),
            _buildReviewsSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(accentColor),
    );
  }

  Color _getSubjectColor(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('数学') || name.contains('math')) {
      return AppTheme.primaryColor;
    } else if (name.contains('英语') || name.contains('english')) {
      return const Color(0xFF10B981);
    } else if (name.contains('物理') || name.contains('physics')) {
      return const Color(0xFFF59E0B);
    } else if (name.contains('化学') || name.contains('chemistry')) {
      return const Color(0xFFEF4444);
    } else if (name.contains('生物') || name.contains('biology')) {
      return const Color(0xFF14B8A6);
    }
    return AppTheme.primaryColor;
  }

  Widget _buildHeaderSection(Color accentColor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.userProfile,
          arguments: {
            'userId': _currentTutor.user.id.toString(),
            'userName': _currentTutor.user.name,
          },
        );
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      _currentTutor.user.name[0],
                      style: TextStyle(
                        fontSize: 36,
                        color: accentColor,
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
                          Flexible(
                            child: Text(
                              _currentTutor.user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (_currentTutor.user.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
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
                                      fontSize: 10,
                                      color: Color(0xFF0EA5E9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentTutor.rating.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentTutor.reviewCount}条评价',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: _currentTutor.subjects.map((subject) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBasicInfoSection(Color accentColor) {
    final gradeLevels = _currentTutor.targetGradeLevels.map((g) => g.displayName).join('、');
    final subjects = _currentTutor.subjects.map((s) => s.name).join('、');
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本信息',
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
                child: _buildInfoRow(
                  Icons.school_outlined,
                  '目标学段',
                  gradeLevels.isNotEmpty ? gradeLevels : '暂无信息',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(
                  Icons.book_outlined,
                  '目标科目',
                  subjects.isNotEmpty ? subjects : '暂无信息',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            '授课区域',
            _currentTutor.address ?? '暂无信息',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '时薪',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '¥${_currentTutor.pricePerHour}/小时',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEducationSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
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
                  _currentTutor.educationBackground.isNotEmpty ? _currentTutor.educationBackground : '暂无信息',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEducationCard(
                  Icons.account_balance_outlined,
                  '院校',
                  _currentTutor.user.school ?? '暂无信息',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEducationCard(
            Icons.menu_book_outlined,
            '专业',
            (_currentTutor.user.major ?? '').isNotEmpty ? _currentTutor.user.major! : '暂无信息',
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachingSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '教学特色',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('认真负责'),
              _buildTag('耐心细致'),
              _buildTag('因材施教'),
              _buildTag('方法灵活'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildIntroductionSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '描述',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentTutor.description.isNotEmpty
                ? _currentTutor.description
                : '暂无描述',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '学员评价',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/my-reviews',
                    arguments: {'tutorId': _currentTutor.id},
                  );
                },
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingReviews)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isNotEmpty)
            ...List.generate(_reviews.length > 2 ? 2 : _reviews.length, (index) {
              final review = _reviews[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReviewItem(
                  review.reviewer.name,
                  review.content,
                  review.rating,
                  review.createdAt.toString().split(' ')[0],
                ),
              );
            })
          else
            const Text(
              '暂无评价',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String content, double rating, String date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
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
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Color accentColor) {
    if (_isOwnService) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('聊天功能正在开发中')),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: accentColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                '联系家教',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _hasBooked || _isOwnService
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplicationFormPage(
                            requestId: _currentTutor.id,
                            requestType: 'tutor_profile',
                            title: '申请家教',
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: (_hasBooked || _isOwnService) ? Colors.grey : accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _isOwnService ? '自己的家教信息' : (_hasBooked ? '已报名' : '我要报名'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
