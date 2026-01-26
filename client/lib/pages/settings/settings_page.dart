import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';
import 'package:provider/provider.dart';
import '../auth/role_selection_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
          '设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (Provider.of<AuthProvider>(context).isAuthenticated)
              _buildSection('账号设置', [
                _buildSettingItem(
                  Icons.person_rounded,
                  '个人资料',
                  () => Navigator.pushNamed(context, Routes.profileEdit),
                ),
                _buildSettingItem(
                  Icons.security_rounded,
                  '账号安全',
                  () => Navigator.pushNamed(context, Routes.accountSecurity),
                ),
                _buildSettingItem(
                  Icons.block_rounded,
                  '黑名单',
                  () => Navigator.pushNamed(context, Routes.blacklist),
                ),
                _buildSettingItem(
                  Icons.swap_horiz_rounded,
                  '角色切换',
                  () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final user = authProvider.user;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RoleSelectionPage(userId: user.id)),
                      );
                    }
                  },
                ),
              ]),
            const SizedBox(height: 16),
            _buildSection('关于', [
              _buildSettingItem(
                Icons.description_rounded,
                '用户协议',
                () => Navigator.pushNamed(context, Routes.userAgreement),
              ),
              _buildSettingItem(
                Icons.privacy_tip_rounded,
                '隐私政策',
                () => Navigator.pushNamed(context, Routes.privacyPolicy),
              ),
              _buildSettingItem(
                Icons.info_rounded,
                '关于我们',
                () => Navigator.pushNamed(context, Routes.aboutUs),
              ),
              _buildSettingItem(
                Icons.update_rounded,
                '检查更新',
                () {},
              ),
            ]),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            if (Provider.of<AuthProvider>(context).isAuthenticated)
              _buildLogoutButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('退出登录'),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          '确定要退出登录吗？',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/sms-login');
            },
            child: const Text(
              '确定',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
