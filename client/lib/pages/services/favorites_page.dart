import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/tutor_model.dart';
import '../tutor_service/tutor_service_detail_page.dart';
import '../student_request/student_request_detail_page.dart';
import '../../utils/error_handler.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _favorites = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('用户未登录');
      }

      final response = await ApiService.getFavorites(userId.toString());

      if (!mounted) return;

      if (response is Map) {
        if (response['success'] == true) {
          final data = response['data'];
          if (data is List) {
            setState(() {
              _favorites = data.cast<Map<String, dynamic>>();
            });
          }
        } else {
          throw Exception(response['message'] ?? '加载失败');
        }
      } else {
        throw Exception('无效的响应格式');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _favorites = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(Map<String, dynamic> favorite) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) return;

      await ApiService.removeFavorite(
        userId,
        favorite['targetId']?.toString() ?? '',
        favorite['targetType'] ?? 'tutor_profile',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已取消收藏')),
        );
        _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('取消收藏失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('我的收藏'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            color: AppTheme.textPrimary,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _favorites.isEmpty
                    ? _buildEmptyState()
                    : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              '暂无收藏',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '收藏的家教会显示在这里',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.textTertiary,
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
            onPressed: _loadFavorites,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        return _buildFavoriteCard(favorite);
      },
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    final targetType = favorite['targetType'] ?? 'tutor_profile';
    final isTutor = targetType == 'tutor_profile' || targetType == 'tutor';
    final targetData = favorite['target'] ?? {};
    final targetId = favorite['targetId']?.toString() ?? '';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          if (targetId.isNotEmpty) {
            try {
              if (isTutor) {
                final response = await ApiService.getService(targetId);
                if (response is Map && response['success'] == true) {
                  final tutorData = response['data'];
                  final tutor = Tutor.fromJson(tutorData);
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TutorServiceDetailPage(tutor: tutor),
                      ),
                    );
                  }
                }
              } else {
                final response = await ApiService.getStudentRequestById(targetId);
                if (response is Map && response['success'] == true) {
                  final requestData = response['data'];
                  final request = Tutor.fromJson(requestData);
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentRequestDetailPage(request: request),
                      ),
                    );
                  }
                }
              }
            } catch (e) {
              if (mounted) {
                ErrorHandler.showErrorSnackBar(context, e);
              }
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(
                  isTutor ? Icons.person : Icons.school,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTutor
                          ? (targetData['username'] ?? '未知家教')
                          : (targetData['username'] ?? '未知需求'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTutor
                          ? (targetData['subjectName'] ?? '家教信息')
                          : (targetData['childGrade'] ?? '学生需求'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => _removeFavorite(favorite),
              ),
            ],
          ),
        ),
      ),
    );
  }
}