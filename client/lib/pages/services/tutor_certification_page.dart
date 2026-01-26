import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class TutorCertificationPage extends StatefulWidget {
  const TutorCertificationPage({super.key});

  @override
  State<TutorCertificationPage> createState() => _TutorCertificationPageState();
}

class _TutorCertificationPageState extends State<TutorCertificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idCardController = TextEditingController();
  final _schoolController = TextEditingController();
  final _majorController = TextEditingController();
  final _certificateController = TextEditingController();
  
  String? _selectedEducation;
  
  bool _isLoading = false;
  bool _isCheckingStatus = true;
  Map<String, dynamic>? _certificationData;

  static const List<String> _educationOptions = [
    '初中及以下',
    '高中',
    '大专',
    '本科',
    '硕士',
    '博士及以上'
  ];

  @override
  void initState() {
    super.initState();
    _checkCertificationStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idCardController.dispose();
    _schoolController.dispose();
    _majorController.dispose();
    _certificateController.dispose();
    super.dispose();
  }

  Future<void> _checkCertificationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      setState(() {
        _isCheckingStatus = false;
      });
      return;
    }

    try {
      final response = await ApiService.getTutorCertification(userId);
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _certificationData = response['data'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _certificationData = null;
        });
      }
    } finally {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  Future<void> _submitCertification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEducation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择学历')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.submitTutorCertification({
        'userId': userId,
        'realName': _nameController.text,
        'idCard': _idCardController.text,
        'education': _selectedEducation,
        'school': _schoolController.text,
        'major': _majorController.text,
        'certificateNumber': _certificateController.text,
      });

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('认证申请已提交，请等待审核')),
          );
          await _checkCertificationStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? '提交失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _viewApprovedCertification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApprovedCertificationPage(certificationData: _certificationData!),
      ),
    );
  }

  void _resubmitCertification() {
    if (_certificationData != null) {
      _nameController.text = _certificationData!['realName'] ?? '';
      _idCardController.text = _certificationData!['idCard'] ?? '';
      _selectedEducation = _certificationData!['education'];
      _schoolController.text = _certificationData!['school'] ?? '';
      _majorController.text = _certificationData!['major'] ?? '';
      _certificateController.text = _certificationData!['certificateNumber'] ?? '';
    }
    setState(() {
      _certificationData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStatus) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('家教认证'),
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_certificationData != null) {
      final status = _certificationData!['status'];
      
      if (status == 'pending') {
        return _buildPendingStatus();
      } else if (status == 'approved') {
        return _buildApprovedStatus();
      } else if (status == 'rejected') {
        return _buildRejectedStatus();
      }
    }

    return _buildForm();
  }

  Widget _buildPendingStatus() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('家教认证'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pending_actions,
                  size: 40,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '认证正在审核中',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '您的认证申请正在审核中，请耐心等待',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovedStatus() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('家教认证'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified,
                  size: 40,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '身份已认证',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '您的家教认证已审核通过',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _viewApprovedCertification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '查看认证信息',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildRejectedStatus() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('家教认证'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel,
                  size: 40,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '认证审核不通过',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '您的认证申请未通过审核',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _resubmitCertification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '重新提交',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildForm() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('家教认证'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('基本信息'),
                const SizedBox(height: 12),
                _buildTextField(
                  _nameController,
                  '真实姓名',
                  '请输入真实姓名',
                  Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入真实姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _idCardController,
                  '身份证号',
                  '请输入身份证号',
                  Icons.badge_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入身份证号';
                    }
                    if (value.length != 18) {
                      return '身份证号格式不正确';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('学历信息'),
                const SizedBox(height: 12),
                _buildEducationDropdown(),
                const SizedBox(height: 12),
                _buildTextField(
                  _schoolController,
                  '毕业院校',
                  '请输入毕业院校',
                  Icons.account_balance_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入毕业院校';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _majorController,
                  '专业',
                  '请输入专业',
                  Icons.menu_book_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入专业';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('证书信息'),
                const SizedBox(height: 12),
                _buildTextField(
                  _certificateController,
                  '教师资格证号',
                  '请输入教师资格证号',
                  Icons.workspace_premium_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入教师资格证号';
                    }
                    if (!RegExp(r'^\d{17}$').hasMatch(value)) {
                      return '教师资格证号必须为17位数字';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitCertification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '提交认证',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildEducationDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedEducation,
        decoration: const InputDecoration(
          labelText: '学历',
          hintText: '请选择学历',
          prefixIcon: Icon(Icons.school_rounded, color: AppTheme.primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: _educationOptions.map((String education) {
          return DropdownMenuItem<String>(
            value: education,
            child: Text(education),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEducation = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请选择学历';
          }
          return null;
        },
        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class ApprovedCertificationPage extends StatelessWidget {
  final Map<String, dynamic> certificationData;

  const ApprovedCertificationPage({
    super.key,
    required this.certificationData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('好会帮认证证书'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 50,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '好会帮认证证书',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '已认证',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.dividerColor),
                  const SizedBox(height: 24),
                  _buildInfoRow('真实姓名', certificationData['realName'] ?? ''),
                  const SizedBox(height: 16),
                  _buildInfoRow('身份证号', certificationData['idCard'] ?? ''),
                  const SizedBox(height: 16),
                  _buildInfoRow('学历', certificationData['education'] ?? ''),
                  const SizedBox(height: 16),
                  _buildInfoRow('毕业院校', certificationData['school'] ?? ''),
                  const SizedBox(height: 16),
                  _buildInfoRow('专业', certificationData['major'] ?? ''),
                  const SizedBox(height: 16),
                  _buildInfoRow('教师资格证号', certificationData['certificateNumber'] ?? ''),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.dividerColor),
                  const SizedBox(height: 16),
                  _buildInfoRow('认证时间', _formatDate(certificationData['createTime'])),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '兹证明${certificationData['realName'][0]}老师已通过好会帮资格审核',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text('：'),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    return date.toString().split('T')[0];
  }
}
