import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../pages/main/main_tab_page.dart';
import '../../providers/auth_provider.dart';

class RoleSelectionPage extends StatelessWidget {
  final String userId;

  const RoleSelectionPage({super.key, required this.userId});

  Future<void> _selectRole(BuildContext context, String roleId) async {

    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      
      await authProvider.updateUserRole(roleId, userId);

      
      if (!context.mounted) return;
      
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const MainTabPage()),
      );
    } catch (e) {

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('身份选择失败: ${e.toString()}')),
      );
    }
  }

  Widget _buildRoleOption(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '选择您的身份',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '请选择您在平台上的主要身份',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildRoleOption(
                          '我要做家教',
                          '成为家教，分享知识，赚取收入',
                          Icons.school_outlined,
                          AppTheme.primaryColor,
                          () => _selectRole(context, 'tutor'),
                        ),
                        _buildRoleOption(
                          '我要请家教',
                          '寻找合适的家教，提升学习成绩',
                          Icons.search,
                          const Color(0xFF10B981),
                          () => _selectRole(context, 'student'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Center(
                  child: Text(
                    '您可以随时在个人中心修改身份',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
