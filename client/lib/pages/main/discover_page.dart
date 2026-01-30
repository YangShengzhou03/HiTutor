import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/tutor_provider.dart';
import '../../models/tutor_model.dart';
import '../student_request/student_request_detail_page.dart';
import '../tutor_service/tutor_service_detail_page.dart';
import '../../routes.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  static const _padding12 = EdgeInsets.all(12);
  static const _paddingH16 = EdgeInsets.symmetric(horizontal: 16);
  static const _paddingH8V4 = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static final _borderRadius12 = BorderRadius.circular(12);
  static final _borderRadius14 = BorderRadius.circular(14);
  static final _borderRadius24 = BorderRadius.circular(24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 44,
      padding: _paddingH16,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '发现',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<TutorProvider>(
      builder: (context, provider, child) {
        return ListView(
          padding: _padding12,
          children: [
            _buildCategoriesSection(context, provider),
            const SizedBox(height: 12),
            _buildHotTutorsSection(provider),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesSection(BuildContext context, TutorProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildCategoryGrid(context, provider),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, TutorProvider provider) {
    final categories = [
      {
        'icon': Icons.calculate_rounded,
        'name': '数学',
        'color': AppTheme.primaryColor
      },
      {
        'icon': Icons.translate_rounded,
        'name': '英语',
        'color': const Color(0xFF10B981)
      },
      {
        'icon': Icons.science_rounded,
        'name': '物理',
        'color': const Color(0xFFF59E0B)
      },
      {
        'icon': Icons.biotech_rounded,
        'name': '化学',
        'color': const Color(0xFF722ED1)
      },
      {
        'icon': Icons.menu_book_rounded,
        'name': '语文',
        'color': const Color(0xFF14B8A6)
      },
      {
        'icon': Icons.history_edu_rounded,
        'name': '历史',
        'color': const Color(0xFFEC4899)
      },
      {
        'icon': Icons.public_rounded,
        'name': '地理',
        'color': const Color(0xFF6366F1)
      },
      {
        'icon': Icons.music_note_rounded,
        'name': '音乐',
        'color': const Color(0xFF8B5CF6)
      },
      {
        'icon': Icons.sports_soccer_rounded,
        'name': '体育',
        'color': const Color(0xFF10B981)
      },
      {
        'icon': Icons.palette_rounded,
        'name': '美术',
        'color': const Color(0xFF14B8A6)
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: categories
          .map((category) => _buildCategoryItem(
                context,
                provider,
                category['icon'] as IconData,
                category['name'] as String,
                category['color'] as Color,
              ))
          .toList(),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    TutorProvider provider,
    IconData icon,
    String label,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.subjectExplore,
          arguments: label,
        );
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: _borderRadius12,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotTutorsSection(TutorProvider provider) {
    if (provider.isLoading && provider.tutors.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage.isNotEmpty && provider.tutors.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          '加载失败: ${provider.errorMessage}',
          style: const TextStyle(color: AppTheme.errorColor),
        ),
      );
    }

    final hotTutors = [...provider.tutors]
      ..sort((a, b) => b.rating.compareTo(a.rating))
      ..take(5);

    if (hotTutors.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 48,
              color: AppTheme.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              '暂无热门家教',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '热门家教',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hotTutors.length,
            itemBuilder: (context, index) =>
                _buildHotTutorCard(context, hotTutors.elementAt(index)),
          ),
        ),
      ],
    );
  }

  Widget _buildHotTutorCard(BuildContext context, Tutor tutor) {
    Color accentColor;
    switch (tutor.subjects.firstOrNull?.name.toLowerCase()) {
      case '数学':
      case 'math':
        accentColor = AppTheme.primaryColor;
        break;
      case '英语':
      case 'english':
        accentColor = const Color(0xFF10B981);
        break;
      case '物理':
      case 'physics':
        accentColor = const Color(0xFFF59E0B);
        break;
      case '化学':
      case 'chemistry':
        accentColor = const Color(0xFFEF4444);
        break;
      case '生物':
      case 'biology':
        accentColor = const Color(0xFF14B8A6);
        break;
      default:
        accentColor = AppTheme.primaryColor;
    }

    String displayPrice = _getDisplayPrice(tutor.pricePerHour);

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
    subtitle += tutor.educationBackground;
    if (tutor.subjects.isNotEmpty) {
      if (subtitle.isNotEmpty) subtitle += ' · ';
      subtitle += tutor.subjects.map((subject) => subject.name).join('、');
    }

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
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: _padding12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _borderRadius14,
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: _borderRadius24,
                  ),
                  child: Center(
                    child: Text(
                      tutor.user.name.isNotEmpty ? tutor.user.name[0] : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
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
                        children: [
                          Flexible(
                            child: Text(
                              tutor.user.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tutor.user.isVerified == true)
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.verified,
                                size: 11,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          if (tutor.user.badge != null && tutor.user.badge!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF2F8),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  tutor.user.badge!,
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
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (tutor.user.gender != null && tutor.user.gender!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                (tutor.user.gender!.toLowerCase() == 'male' || tutor.user.gender == '男') ? '♂' : '♀',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: (tutor.user.gender!.toLowerCase() == 'male' || tutor.user.gender == '男') ? AppTheme.maleColor : AppTheme.femaleColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Flexible(
                            child: Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
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
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map((tag) => Container(
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
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tutor.rating.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                Text(
                  '¥$displayPrice/小时',
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
    );
  }

  String _getDisplayPrice(String pricePerHour) {
    if (pricePerHour.contains('-')) {
      final parts = pricePerHour.split('-');
      if (parts.length == 2) {
        return parts[1].trim();
      }
    }
    return pricePerHour;
  }
}
