import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'main_tab_page.dart';
import '../auth/sms_login_page.dart';
import '../auth/role_selection_page.dart';

class SplashAdPage extends StatefulWidget {
  const SplashAdPage({super.key});

  @override
  State<SplashAdPage> createState() => _SplashAdPageState();
}

class _SplashAdPageState extends State<SplashAdPage> {
  int _countdown = 3;
  late Timer _timer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    setState(() {
      _isInitialized = true;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer.cancel();
          _jumpToNextPage();
        }
      });
    });
  }

  void _jumpToNextPage() {
    if (!_isInitialized) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn) {
      if (authProvider.isFirstLogin) {
        final userId = authProvider.user?.id ?? '';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RoleSelectionPage(userId: userId),
          ),
        );
      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainTabPage()),
        );
      }
    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SmsLoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            _buildLogo(),
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Align(
      alignment: Alignment(0, -0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
          '好会帮',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '上好会帮，赢好未来',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      right: 16,
      child: GestureDetector(
        onTap: () {
          _timer.cancel();
          _jumpToNextPage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '跳过 $_countdown',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
