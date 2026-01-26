import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'home_page.dart';
import 'message_page.dart';
import 'discover_page.dart';
import 'profile_page.dart';


class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;

  static const _pages = [
    HomePage(),
    MessagePage(),
    DiscoverPage(),
    ProfilePage(),
  ];

  static const _navHeight = 56.0;
  static const _iconSize = 32.0;
  static const _padding16 = EdgeInsets.all(16);
  static const _paddingH16V14 = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static final _borderRadius12 = BorderRadius.circular(12);
  static final _borderRadius20 = BorderRadius.circular(20);
  static final _borderRadius24 = BorderRadius.circular(24);

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Container(
                  height: _navHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildNavItem(Icons.home_rounded, '首页', 0)),
                      Expanded(child: _buildNavItem(Icons.message_rounded, '消息', 1)),
                      Expanded(child: _buildPublishButton()),
                      Expanded(child: _buildNavItem(Icons.explore_rounded, '发现', 2)),
                      Expanded(child: _buildNavItem(Icons.person_rounded, '我的', 3)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _navHeight,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
                borderRadius: _borderRadius20,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    return GestureDetector(
      onTap: _showPublishMenu,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _navHeight,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: _borderRadius24,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '发布',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPublishMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: _padding16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '发布内容',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.dividerColor),
              _buildMenuItem(Icons.school_rounded, '我要请家教', '发布家教需求'),
              _buildMenuItem(Icons.work_rounded, '我要做家教', '发布家教信息'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (title == '我要请家教') {
          Navigator.pushNamed(context, '/publish-student-request');
        } else if (title == '我要做家教') {
          Navigator.pushNamed(context, '/publish-tutor-service');
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: _paddingH16V14,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: _borderRadius12,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}