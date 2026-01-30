import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/tutor_model.dart';
import '../../utils/error_handler.dart';
import '../application/application_list_page.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyPublishingsPage extends StatefulWidget {
  const MyPublishingsPage({super.key});

  @override
  State<MyPublishingsPage> createState() => _MyPublishingsPageState();
}

class _MyPublishingsPageState extends State<MyPublishingsPage> {
  bool _isLoading = true;
  List<dynamic> _allPublishings = [];

  @override
  void initState() {
    super.initState();
    _loadPublishings();
  }

  Future<void> _loadPublishings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null || userId.isEmpty) {
        setState(() {
          _isLoading = false;
          _allPublishings = [];
        });
        return;
      }

      final requestsResponse = await ApiService.getUserRequestsWithUserId(userId);
      final servicesResponse = await ApiService.getUserServicesWithUserId(userId);

      
      final studentRequests = (requestsResponse['data']?['content'] ?? [])
          .map((request) => {
                ...request,
                'type': 'request',
                'typeText': '家教需求',
                'typeColor': const Color(0xFF10B981), 
              })
          .toList();

      
      final tutorServices = (servicesResponse['data']?['content'] ?? [])
          .map((service) => {
                ...service,
                'type': 'service',
                'typeText': '家教信息',
                'typeColor': AppTheme.primaryColor, 
              })
          .toList();

      
      final combinedPublishings = [...studentRequests, ...tutorServices];
      combinedPublishings.sort((a, b) {
        final dateA = a['createdAt'] != null ? DateTime.tryParse(a['createdAt']) : DateTime.now();
        final dateB = b['createdAt'] != null ? DateTime.tryParse(b['createdAt']) : DateTime.now();
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      setState(() {
        _allPublishings = combinedPublishings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          '我的发布',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _allPublishings.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            '暂无发布内容',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: _allPublishings
                        .map((item) => _buildPublishingItem(item))
                        .toList(),
                  ),
      ),
    );
  }

  Future<void> _deletePublishing(dynamic item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这条${item['typeText']}吗？\n删除后将无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (item['type'] == 'request') {
        await ApiService.deleteRequest(item['id'].toString());
      } else {
        await ApiService.deleteService(item['id'].toString());
      }
      setState(() {
        _allPublishings.remove(item);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildPublishingItem(dynamic item) {
    
    final createTime = item['createdAt'] != null 
        ? DateTime.parse(item['createdAt']) 
        : DateTime.now();
    final formattedDate = '${createTime.year}-${createTime.month.toString().padLeft(2, '0')}-${createTime.day.toString().padLeft(2, '0')} ${createTime.hour.toString().padLeft(2, '0')}:${createTime.minute.toString().padLeft(2, '0')}';

    final isVerified = item['userVerified'] as bool?;
    final badge = item['badge']?.toString();
    final gender = item['userGender']?.toString() ?? item['gender']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(right: BorderSide(color: item['typeColor'], width: 4)),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
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
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item['subjectName'] ?? '未命名',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (gender != null && gender.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                gender == 'male' ? '♂' : '♀',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: gender == 'male' ? AppTheme.maleColor : AppTheme.femaleColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          if (isVerified == true)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 10, color: Colors.blue.shade700),
                                    const SizedBox(width: 2),
                                    Text(
                                      '已认证',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (badge != null && badge.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF2F8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  badge,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFEC4899),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (item['type'] == 'service' && item['targetGradeLevels'] != null)
                      _buildGradeLevelsInline(item['targetGradeLevels']),
                    if (item['type'] == 'request' && item['childGrade'] != null)
                      _buildChildGradeInline(item['childGrade']),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item['typeColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['typeText'],
                        style: TextStyle(
                          fontSize: 12,
                          color: item['typeColor'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deletePublishing(item),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['requirements'] ?? item['description'] ?? '暂无描述',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['type'] == 'request'
                    ? '${item['hourlyRateMin']}-${item['hourlyRateMax']}元/小时'
                    : '${item['hourlyRate']}元/小时',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item['typeColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: item['typeColor'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApplicationListPage(
                      requestId: item['id'].toString(),
                      requestType: item['type'] == 'request' ? 'student_request' : 'tutor_profile',
                    ),
                  ),
                );
                if (result == true) {
                  _loadPublishings();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: item['typeColor'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                '查看报名列表',
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

  Widget _buildGradeLevelsInline(dynamic gradeLevelsData) {
    List<String> gradeLevelNames = [];
    
    if (gradeLevelsData is String && gradeLevelsData.isNotEmpty) {
      final gradeLevelIds = gradeLevelsData.split(',');
      gradeLevelNames = gradeLevelIds.map((id) {
        final gradeLevel = GradeLevel.allGradeLevels.firstWhere(
          (gl) => gl.id == id,
          orElse: () => GradeLevel(id: id, name: id, displayName: id),
        );
        return gradeLevel.displayName;
      }).toList();
    } else if (gradeLevelsData is List) {
      gradeLevelNames = gradeLevelsData.map((gl) {
        if (gl is Map) {
          return gl['displayName'] ?? gl['name'] ?? '';
        }
        return gl.toString();
      }).cast<String>().toList();
    }
    
    if (gradeLevelNames.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: gradeLevelNames.map((name) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChildGradeInline(String childGrade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        childGrade,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF10B981),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
