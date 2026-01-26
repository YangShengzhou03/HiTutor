import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'role_selection_page.dart';
import 'package:provider/provider.dart';

class SmsLoginPage extends StatefulWidget {
  const SmsLoginPage({super.key});

  @override
  State<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _isLoading = false;
  bool _isSendingCode = false;
  int _countdown = 0;

  bool get _isFormValid {
    final phone = _phoneController.text.trim();
    final code = _verificationCodeController.text.trim();
    return phone.isNotEmpty &&
        RegExp(r'^1[3-9]\d{9}$').hasMatch(phone) &&
        code.isNotEmpty &&
        code.length == 6;
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_updateFormState);
    _verificationCodeController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {});
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入正确的手机号')));
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    try {
      await ApiService.sendVerificationCode(phone);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('验证码已发送')));

      setState(() {
        _countdown = 60;
      });

      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _countdown--;
      });
      return _countdown > 0;
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final phone = _phoneController.text.trim();
        final verificationCode = _verificationCodeController.text.trim();

        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final response = await ApiService.loginBySms(
          phone,
          verificationCode,
          'student',
        );

        if (response['success'] == true) {
          final data = response['data'];
          final user = data['user'];
          final token = data['token'];
          final isFirstLogin = data['isFirstLogin'] ?? false;

          await authProvider.loginWithToken(user, token, isFirstLogin: isFirstLogin);

          if (!mounted) return;
          
          if (isFirstLogin) {
            final userId = (user['id'] != null) ? user['id'].toString() : '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RoleSelectionPage(userId: userId),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/main-tab');
          }
        } else {
          throw Exception(response['message'] ?? '登录失败');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        '好会帮',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        '上好会帮，赢好未来',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: '手机号',
                              hintText: '请输入手机号',
                              prefixIcon: Icon(Icons.phone_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入手机号';
                              }
                              if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                                return '请输入正确的手机号';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _verificationCodeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '验证码',
                                    hintText: '请输入验证码',
                                    prefixIcon: Icon(Icons.verified_user_rounded),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入验证码';
                                    }
                                    if (value.length != 6) {
                                      return '验证码长度为6位';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 120,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed:
                                      (_isSendingCode ||
                                          _countdown > 0 ||
                                          _phoneController.text.isEmpty)
                                      ? null
                                      : _sendVerificationCode,
                                  child: _isSendingCode
                                      ? const SizedBox(
                                          width: 20,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _countdown > 0
                                              ? '${_countdown}s'
                                              : '获取验证码',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (_isLoading || !_isFormValid)
                                  ? null
                                  : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('登录/注册'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '未注册的手机号验证通过后将自动创建账号',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/password-login');
                                },
                                child: const Text(
                                  '密码登录',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '登录即代表同意',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/user-agreement');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '《用户许可协议》',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      '和',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/privacy-policy');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '《隐私政策》',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
