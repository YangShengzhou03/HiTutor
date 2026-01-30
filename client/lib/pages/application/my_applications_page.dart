import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _applications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('用户未登录');
      }

      final response = await ApiService.getApplicationsByApplicantId(userId);
      
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

  void _reloadData() {
    _loadApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('我的报名'),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('重新加载'),
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
                            Icons.assignment_turned_in_rounded,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '暂无报名记录',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadApplications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _applications.length,
                        itemBuilder: (context, index) {
                          final app = _applications[index];
                          return _buildApplicationCard(app);
                        },
                      ),
                    ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final status = app['status'] ?? 'pending';
    final statusInfo = _getStatusInfo(status);
    final requestType = app['requestType'] ?? 'student_request';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
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
                    requestType == 'student_request' ? '学生需求' : '家教信息',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (app['tutorVerified'] == true || app['tutorVerified'] == 1)
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
            Icons.person_outline,
            '报名留言',
            app['message'] ?? '无',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            '报名时间',
            _formatDateTime(app['createTime'] ?? ''),
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
        return const {
          'label': '等待筛选',
          'color': Color(0xFFF59E0B),
        };
      case 'accepted':
        return const {
          'label': '已选中',
          'color': Color(0xFF3B82F6),
        };
      case 'confirmed':
        return const {
          'label': '已确认',
          'color': Color(0xFF10B981),
        };
      case 'rejected':
        return const {
          'label': '已拒绝',
          'color': Color(0xFFEF4444),
        };
      default:
        return const {
          'label': '未知',
          'color': AppTheme.textSecondary,
        };
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '未知';
    
    String dateTimeStr = dateTime.toString();
    
    DateTime? parsedDate;
    
    if (dateTimeStr.contains('T')) {
      parsedDate = DateTime.tryParse(dateTimeStr);
    } else if (dateTimeStr.contains(' ')) {
      final parts = dateTimeStr.split(' ');
      if (parts.length >= 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');
        if (dateParts.length == 3 && timeParts.length >= 3) {
          try {
            parsedDate = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
              int.parse(timeParts[2]),
            );
          } catch (e) {
            return '未知';
          }
        }
      }
    } else {
      parsedDate = DateTime.tryParse(dateTimeStr);
    }
    
    if (parsedDate == null) return '未知';
    
    return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
  }
}
