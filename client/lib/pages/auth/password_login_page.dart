import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'role_selection_page.dart';
import 'package:provider/provider.dart';

class PasswordLoginPage extends StatefulWidget {
  const PasswordLoginPage({super.key});

  @override
  State<PasswordLoginPage> createState() => _PasswordLoginPageState();
}

class _PasswordLoginPageState extends State<PasswordLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get _isFormValid {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    return phone.isNotEmpty &&
           RegExp(r'^1[3-9]\d{9}$').hasMatch(phone) &&
           password.isNotEmpty &&
           password.length >= 6;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final phone = _phoneController.text.trim();
        final password = _passwordController.text.trim();
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final response = await ApiService.loginByPassword(phone, password);
        
        if (response['success'] == true) {
          final data = response['data'];
          final user = data['user'];
          final accessToken = data['accessToken'] ?? data['token'];
          final isFirstLogin = data['isFirstLogin'] ?? false;
          
          await authProvider.loginWithToken(user, accessToken, isFirstLogin: isFirstLogin);
          
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
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
                      onChanged: (value) {
                        setState(() {});
                      },
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: '密码',
                        hintText: '请输入密码',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入密码';
                        }
                        if (value.length < 6) {
                          return '密码长度不能少于6位';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_isLoading || !_isFormValid) ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('登录'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/sms-login');
                          },
                          child: const Text(
                            '验证码登录/注册',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text(
                            '忘记密码？',
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
    );
  }
}
