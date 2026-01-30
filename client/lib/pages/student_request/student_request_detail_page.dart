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

class StudentRequestDetailPage extends StatefulWidget {
  final Tutor request;

  const StudentRequestDetailPage({super.key, required this.request});

  @override
  State<StudentRequestDetailPage> createState() => _StudentRequestDetailPageState();
}

class _StudentRequestDetailPageState extends State<StudentRequestDetailPage> {
  bool _isFavorite = false;
  bool _isLoading = false;
  bool _hasApplied = false;
  bool _isOwnRequest = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
    _loadFavoriteStatus();
    _checkOwnership();
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
        final requestIdLong = int.tryParse(widget.request.id);
        final isFavorite = favorites.any((item) {
          if (item is Map) {
            final targetType = item['targetType'];
            final targetId = item['targetId'];
            return (targetType == 'student_request' || targetType == 'student_request_profile') && 
                   targetId == requestIdLong;
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

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await ApiService.removeFavorite(userId, widget.request.id, 'student_request');
      } else {
        final targetIdLong = int.tryParse(widget.request.id);
        if (targetIdLong == null) {
          throw Exception('无效的需求ID');
        }
        await ApiService.addFavorite({
          'userId': userId,
          'targetType': 'student_request',
          'targetId': targetIdLong,
        });
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkApplicationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        final applications = await ApiService.getApplicationsByRequestId(widget.request.id, 'student_request');
        
        if (applications['success'] == true) {
          final data = applications['data'] ?? [];
          if (data is List) {
            _hasApplied = data.any((app) {
              final applicantId = app['applicantId'];
              return applicantId?.toString() == userId;
            });
          }
        }
      }
    } catch (_) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkOwnership() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    
    if (userId != null) {
      setState(() {
        _isOwnRequest = widget.request.user.id.toString() == userId.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getSubjectColor(widget.request.subjects.firstOrNull?.name ?? '');
    final priceRange = _getPriceRange(widget.request.pricePerHour);

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
          '需求详情',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator(color: Colors.red)
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : AppTheme.textSecondary,
                  ),
            onPressed: _isLoading ? null : _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.report_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComplaintPage(
                    targetUserId: widget.request.user.id,
                  ),
                ),
              );
            },
            color: AppTheme.textSecondary,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能正在开发中')),
              );
            },
            color: AppTheme.textSecondary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(accentColor),
              const SizedBox(height: 16),
              _buildBasicInfoSection(accentColor, priceRange),
              const SizedBox(height: 16),
              _buildRequirementsSection(),
              const SizedBox(height: 16),
              _buildContactSection(),
              const SizedBox(height: 100),
            ],
          ),
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

  String _getPriceRange(String pricePerHour) {
    if (pricePerHour.contains('-')) {
      final parts = pricePerHour.split('-');
      if (parts.length == 2) {
        return '¥${parts[0].trim()}-¥${parts[1].trim()}/小时';
      }
    }
    return '¥$pricePerHour/小时';
  }

  Widget _buildHeaderSection(Color accentColor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.userProfile,
          arguments: {
            'userId': widget.request.user.id.toString(),
            'userName': widget.request.user.username,
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
                      widget.request.user.username.isNotEmpty ? widget.request.user.username[0] : 'U',
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
                              widget.request.user.username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.request.user.badge != null && widget.request.user.badge!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF2F8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.request.user.badge!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFEC4899),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.request.user.gender != null && widget.request.user.gender!.isNotEmpty)
                            Text(
                              (widget.request.user.gender!.toLowerCase() == 'male' || widget.request.user.gender == '男') ? '♂' : '♀',
                              style: TextStyle(
                                fontSize: 14,
                                color: (widget.request.user.gender!.toLowerCase() == 'male' || widget.request.user.gender == '男') ? AppTheme.maleColor : AppTheme.femaleColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Text(
                            widget.request.educationBackground,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.request.subjects.map((subject) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
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
      ),
    );
  }

  Widget _buildBasicInfoSection(Color accentColor, String priceRange) {
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
                  '年级',
                  widget.request.educationBackground,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildInfoRow(
                  Icons.menu_book_outlined,
                  '科目',
                  widget.request.subjects.map((s) => s.name).join('、'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.location_on_outlined,
            '授课地点',
            (widget.request.address != null && widget.request.address!.isNotEmpty) ? widget.request.address! : '暂无地址信息',
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
                  '时薪范围',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  priceRange,
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

  Widget _buildRequirementsSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '需求描述',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.request.description.isNotEmpty
                ? widget.request.description
                : '暂无需求描述',
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

  Widget _buildContactSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '联系方式',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '申请后可查看联系方式',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '提交申请后，学生将收到通知并查看您的信息',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Color accentColor) {
    if (_isOwnRequest) {
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
                '联系学生',
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
              onPressed: _isLoading || _hasApplied || _isOwnRequest
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplicationFormPage(
                            requestId: widget.request.id,
                            requestType: 'student_request',
                            title: '申请家教',
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: (_hasApplied || _isOwnRequest) ? Colors.grey : accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isOwnRequest ? '自己的需求' : (_hasApplied ? '已报名' : '我要报名'),
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