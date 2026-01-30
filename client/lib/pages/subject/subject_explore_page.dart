import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/tutor_model.dart';
import '../tutor_service/tutor_service_detail_page.dart';
import '../student_request/student_request_detail_page.dart';

class SubjectExplorePage extends StatefulWidget {
  final String? defaultSubject;

  const SubjectExplorePage({
    super.key,
    this.defaultSubject,
  });

  @override
  State<SubjectExplorePage> createState() => _SubjectExplorePageState();
}

class _SubjectExplorePageState extends State<SubjectExplorePage> {
  bool _isLoading = false;
  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];
  String _errorMessage = '';
  String _sortBy = 'rating';
  String _priceFilter = 'all';
  String _selectedSubject = '';
  String _selectedType = 'all';

  final List<String> _subjects = [
    '全部',
    '数学',
    '英语',
    '物理',
    '化学',
    '生物',
    '语文',
    '历史',
    '地理',
    '音乐',
    '体育',
    '美术',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.defaultSubject ?? '全部';
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final tutorsResponse = await ApiService.getTutors();
      final requestsResponse = await ApiService.getStudentRequests();

      List<dynamic> data = [];

      if (tutorsResponse is List) {
        for (final item in tutorsResponse) {
          if (item is Map) {
            data.add({...item, 'type': 'tutor_service', 'sourceType': 'tutor'});
          }
        }
      } else if (tutorsResponse is Map && tutorsResponse['success'] == true) {
        final result = tutorsResponse['data'];
        final content = result is Map ? result['content'] ?? [] : result;
        if (content is List) {
          for (final item in content) {
            if (item is Map) {
              data.add({...item, 'type': 'tutor_service', 'sourceType': 'tutor'});
            }
          }
        }
      }

      if (requestsResponse is List) {
        for (final item in requestsResponse) {
          if (item is Map) {
            data.add({...item, 'type': 'student_request', 'sourceType': 'student_request'});
          }
        }
      } else if (requestsResponse is Map && requestsResponse['success'] == true) {
        final result = requestsResponse['data'];
        final content = result is Map ? result['content'] ?? [] : result;
        if (content is List) {
          for (final item in content) {
            if (item is Map) {
              data.add({...item, 'type': 'student_request', 'sourceType': 'student_request'});
            }
          }
        }
      }

      _allItems = data;
      _applyFilters();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _allItems = [];
        _filteredItems = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<dynamic> filtered = List.from(_allItems);

    if (_selectedSubject != '全部') {
      filtered = filtered.where((item) {
        final subject = item['subjectName']?.toString() ?? '';
        return subject.contains(_selectedSubject);
      }).toList();
    }

    if (_selectedType != 'all') {
      filtered = filtered.where((item) {
        return item['sourceType'] == _selectedType;
      }).toList();
    }

    if (_priceFilter != 'all') {
      filtered = filtered.where((item) {
        final price = item['hourlyRate']?.toString() ?? item['hourlyRateMin']?.toString() ?? '0';
        final priceValue = double.tryParse(price) ?? 0;
        
        if (_priceFilter == 'low') {
          return priceValue < 100;
        } else if (_priceFilter == 'medium') {
          return priceValue >= 100 && priceValue < 200;
        } else if (_priceFilter == 'high') {
          return priceValue >= 200;
        }
        return true;
      }).toList();
    }

    if (_sortBy == 'rating') {
      filtered.sort((a, b) {
        final ratingA = double.tryParse(a['rating']?.toString() ?? '0') ?? 0;
        final ratingB = double.tryParse(b['rating']?.toString() ?? '0') ?? 0;
        return ratingB.compareTo(ratingA);
      });
    } else if (_sortBy == 'price') {
      filtered.sort((a, b) {
        final priceA = double.tryParse(a['hourlyRate']?.toString() ?? a['hourlyRateMin']?.toString() ?? '0') ?? 0;
        final priceB = double.tryParse(b['hourlyRate']?.toString() ?? b['hourlyRateMin']?.toString() ?? '0') ?? 0;
        return priceA.compareTo(priceB);
      });
    }

    setState(() {
      _filteredItems = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('学科探索'),
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
      body: Column(
        children: [
          _buildCompactFilterBar(),
          Expanded(
            child: _isLoading
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
                              onPressed: _loadItems,
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
                    : _filteredItems.isEmpty
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
                                  '暂无数据',
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
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) => _buildItemCard(
                              Map<String, dynamic>.from(_filteredItems[index] as Map),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterChip(
            icon: Icons.book,
            label: _selectedSubject == '全部' ? '学科' : _selectedSubject,
            onTap: () => _showSubjectFilter(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            icon: Icons.filter_list,
            label: _getTypeLabel(),
            onTap: () => _showTypeFilter(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            icon: Icons.sort,
            label: _getSortLabel(),
            onTap: () => _showSortFilter(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            icon: Icons.attach_money,
            label: _getPriceLabel(),
            onTap: () => _showPriceFilter(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel() {
    switch (_selectedType) {
      case 'tutor':
        return '家教';
      case 'student_request':
        return '需求';
      default:
        return '类型';
    }
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'rating':
        return '评分';
      case 'price':
        return '价格';
      default:
        return '排序';
    }
  }

  String _getPriceLabel() {
    switch (_priceFilter) {
      case 'low':
        return '<100';
      case 'medium':
        return '100-200';
      case 'high':
        return '>200';
      default:
        return '价格';
    }
  }

  void _showSubjectFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择学科',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: _subjects.map((subject) => _buildSubjectOption(subject)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectOption(String subject) {
    final isSelected = _selectedSubject == subject;
    return ListTile(
      title: Text(subject),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        setState(() {
          _selectedSubject = subject;
        });
        _applyFilters();
        Navigator.pop(context);
      },
    );
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _buildTypeOption('all', '全部'),
                  _buildTypeOption('tutor', '家教信息'),
                  _buildTypeOption('student_request', '学生需求'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String value, String label) {
    final isSelected = _selectedType == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        setState(() {
          _selectedType = value;
        });
        _applyFilters();
        Navigator.pop(context);
      },
    );
  }

  void _showSortFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '排序方式',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _buildSortOption('rating', '评分最高'),
                  _buildSortOption('price', '价格最低'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    final isSelected = _sortBy == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        _applyFilters();
        Navigator.pop(context);
      },
    );
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '价格区间',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _buildPriceOption('all', '全部价格'),
                  _buildPriceOption('low', '100元以下'),
                  _buildPriceOption('medium', '100-200元'),
                  _buildPriceOption('high', '200元以上'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOption(String value, String label) {
    final isSelected = _priceFilter == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        setState(() {
          _priceFilter = value;
        });
        _applyFilters();
        Navigator.pop(context);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final isTutor = item['sourceType'] == 'tutor';
    final price = isTutor 
        ? (item['hourlyRate']?.toString() ?? '0')
        : (item['hourlyRateMin']?.toString() ?? '0');
    final description = item['description']?.toString() ?? item['requirements']?.toString() ?? '';
    final address = item['address']?.toString() ?? '';
    final tutor = Tutor.fromJson(item);
    final rating = tutor.rating.toStringAsFixed(1);
    final name = tutor.user.username;
    final avatar = tutor.user.avatar;

    return GestureDetector(
      onTap: () {
        if (isTutor) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorServiceDetailPage(tutor: tutor),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentRequestDetailPage(request: tutor),
            ),
          );
        }
      },
      child: Container(
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
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: avatar.isNotEmpty
                      ? NetworkImage(avatar)
                      : null,
                  child: avatar.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTutor 
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isTutor ? '家教信息' : '学生需求',
                              style: TextStyle(
                                fontSize: 11,
                                color: isTutor 
                                    ? AppTheme.primaryColor
                                    : const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '¥$price/小时',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
