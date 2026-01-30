import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';

class ApplicationListPage extends StatefulWidget {
  final String requestId;
  final String requestType;

  const ApplicationListPage({
    super.key,
    required this.requestId,
    required this.requestType,
  });

  @override
  State<ApplicationListPage> createState() => _ApplicationListPageState();
}

class _ApplicationListPageState extends State<ApplicationListPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _applications = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.getApplicationsByRequestId(widget.requestId, widget.requestType);
      
      List data = [];
      if (response is List) {
        data = response;
      } else if (response is Map && response['success'] == true) {
        data = response['data'] ?? [];
      } else if (response is Map && response['success'] == false) {
        throw Exception(response['message'] ?? '加载失败');
      }

      setState(() {
        _applications = [];
        for (final item in data) {
          if (item is Map<dynamic, dynamic>) {
            _applications.add(Map<String, dynamic>.from(item));
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _applications = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectApplication(String applicationId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户未登录')),
      );
      return;
    }

    final isStudentRequest = widget.requestType == 'student_request';
    final confirmText = isStudentRequest ? '选择后将等待家教确认，确定要继续吗？' : '选择后将等待学生确认，确定要继续吗？';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认选择'),
        content: Text(confirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      for (final app in _applications) {
        final status = app['id'].toString() == applicationId ? 'accepted' : 'rejected';
        await ApiService.updateApplicationStatus(app['id'].toString(), status);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('选择成功，等待对方确认')),
      );
      Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('报名列表'),
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
                        _errorMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadApplications,
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
              : _applications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '暂无报名',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _applications.length,
                      itemBuilder: (context, index) {
                        final app = _applications[index];
                        return _buildApplicationCard(app);
                      },
                    ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final status = app['status'] ?? 'pending';
    final statusInfo = _getStatusInfo(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    app['applicantName'] ?? '未知',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (app['applicantVerified'] == true || app['applicantVerified'] == 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 10,
                              color: Color(0xFF0EA5E9),
                            ),
                            SizedBox(width: 2),
                            Text(
                              '已认证',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF0EA5E9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusInfo['label'],
                  style: TextStyle(
                    fontSize: 12,
                    color: statusInfo['color'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.message_outlined,
            '申请留言',
            app['message'] ?? '无',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time_outlined,
            '报名时间',
            _formatDateTime(app['createdAt'] ?? app['createTime']),
          ),
          const SizedBox(height: 16),
          if (status == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _selectApplication(app['id'].toString()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  '选择并创建预约',
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 8),
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

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'label': '等待筛选',
          'color': const Color(0xFFF59E0B),
        };
      case 'accepted':
        return {
          'label': '已选择',
          'color': const Color(0xFF3B82F6),
        };
      case 'confirmed':
        return {
          'label': '已确认',
          'color': const Color(0xFF10B981),
        };
      case 'rejected':
        return {
          'label': '已拒绝',
          'color': const Color(0xFFEF4444),
        };
      default:
        return {
          'label': '未知',
          'color': AppTheme.textSecondary,
        };
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '未知';
    
    try {
      if (dateTime is String) {
        final parsed = DateTime.parse(dateTime);
        return DateFormat('yyyy-MM-dd HH:mm').format(parsed);
      } else if (dateTime is DateTime) {
        return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
      }
      return '未知';
    } catch (e) {
      return '未知';
    }
  }
}
