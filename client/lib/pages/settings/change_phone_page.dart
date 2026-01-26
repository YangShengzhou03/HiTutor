import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final TextEditingController _currentPhoneController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  final TextEditingController _newPhoneController = TextEditingController();
  final TextEditingController _newVerificationCodeController = TextEditingController();

  bool _isVerifyingCurrent = true;
  bool _isLoading = false;
  bool _canGetCode = true;
  int _countdown = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentPhoneController.text = authProvider.user?.phone ?? '';
  }

  @override
  void dispose() {
    _currentPhoneController.dispose();
    _verificationCodeController.dispose();
    _newPhoneController.dispose();
    _newVerificationCodeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _canGetCode = false;
      _countdown = 60;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else {
        setState(() {
          _canGetCode = true;
        });
      }
    });
  }

  Future<void> _sendVerificationCode() async {
    if (_isVerifyingCurrent && _currentPhoneController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入当前手机号';
      });
      return;
    }

    if (!_isVerifyingCurrent && _newPhoneController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入新手机号';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final phone = _isVerifyingCurrent ? _currentPhoneController.text : _newPhoneController.text;
      await ApiService.sendVerificationCode(phone);
      _startCountdown();
    } catch (e) {
      setState(() {
        _errorMessage = '发送验证码失败，请重试';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyCurrentPhone() async {
    if (_currentPhoneController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入当前手机号';
      });
      return;
    }

    if (_verificationCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入验证码';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      
      await ApiService.verifyCode(
        _currentPhoneController.text,
        _verificationCodeController.text,
        'change_phone',
      );
      setState(() {
        _isVerifyingCurrent = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '验证失败，请检查手机号和验证码';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePhone() async {
    if (_newPhoneController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入新手机号';
      });
      return;
    }

    if (_newVerificationCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入新手机号的验证码';
      });
      return;
    }

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

      
      await ApiService.updateProfile(
        userId,
        {
          'phone': _newPhoneController.text,
        },
      );

      
      await authProvider.initialize();

      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('手机号更换成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = '更换手机号失败，请重试';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          '更换手机号',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isVerifyingCurrent ? '验证当前手机号' : '设置新手机号',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isVerifyingCurrent
                    ? '为了安全，需要先验证您当前绑定的手机号' 
                    : '请输入新的手机号并获取验证码',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
                  ),
                ),

              if (_isVerifyingCurrent) ...[
                _buildTextField(
                  controller: _currentPhoneController,
                  label: '当前手机号',
                  hintText: '请输入当前手机号',
                  keyboardType: TextInputType.phone,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '验证码',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: TextField(
                              controller: _verificationCodeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '请输入验证码',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 130,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _canGetCode && !_isLoading ? _sendVerificationCode : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canGetCode ? AppTheme.primaryColor : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _countdown > 0
                                ? Text('${_countdown}s后重试')
                                : const Text('获取验证码'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: !_isLoading ? _verifyCurrentPhone : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('验证'),
                  ),
                ),
              ] else ...[
                _buildTextField(
                  controller: _newPhoneController,
                  label: '新手机号',
                  hintText: '请输入新手机号',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '验证码',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: TextField(
                              controller: _newVerificationCodeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '请输入验证码',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _canGetCode && !_isLoading ? _sendVerificationCode : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canGetCode ? AppTheme.primaryColor : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _countdown > 0
                                ? Text('${_countdown}s后重试')
                                : const Text('获取验证码'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: !_isLoading ? _changePhone : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('完成更换'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
