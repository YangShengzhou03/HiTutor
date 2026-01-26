import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _majorController = TextEditingController();
  
  String? _gender;
  String? _selectedEducation;
  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _schoolController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    _usernameController.text = user.username ?? '';
    _selectedEducation = user.education;
    _schoolController.text = user.school ?? '';
    _majorController.text = user.major ?? '';
    _gender = user.gender;
    _birthDate = user.birthDate != null ? DateTime.tryParse(user.birthDate!) : null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('用户未登录');
      }

      final profileData = {
        'username': _usernameController.text.trim(),
        'gender': _gender,
        'birthDate': _birthDate != null 
            ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
            : null,
        'education': _selectedEducation,
        'school': _schoolController.text.trim(),
        'major': _majorController.text.trim(),
      };

      await ApiService.updateProfile(userId.toString(), profileData);

      if (!mounted) return;

      
      final updatedUser = await AuthService.getCurrentUser();
      await authProvider.updateUser(updatedUser);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
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
          '个人资料',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text(
              '保存',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 24),
                  _buildUsernameField(),
                  const SizedBox(height: 16),
                  _buildGenderSelector(),
                  const SizedBox(height: 16),
                  _buildBirthDateField(),
                  const SizedBox(height: 16),
                  _buildEducationField(),
                  const SizedBox(height: 16),
                  _buildSchoolField(),
                  const SizedBox(height: 16),
                  _buildMajorField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0] : 'U',
                style: const TextStyle(
                  fontSize: 48,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: '用户名',
        hintText: '请输入用户名',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入用户名';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelector() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '性别',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'male',
                label: Text('男'),
                icon: Icon(Icons.male, size: 16),
              ),
              ButtonSegment(
                value: 'female',
                label: Text('女'),
                icon: Icon(Icons.female, size: 16),
              ),
            ],
            selected: {_gender ?? 'male'},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _gender = newSelection.first;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppTheme.primaryColor.withOpacity(0.1);
                }
                return Colors.transparent;
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppTheme.primaryColor;
                }
                return AppTheme.textSecondary;
              }),
              side: MaterialStateProperty.all(BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDateField() {
    return InkWell(
      onTap: _selectBirthDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '出生日期',
          suffixIcon: Icon(Icons.calendar_today_rounded, size: 20),
        ),
        child: Text(
          _birthDate != null
              ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
              : '请选择出生日期',
          style: TextStyle(
            fontSize: 14,
            color: _birthDate != null ? AppTheme.textPrimary : AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildEducationField() {
    final educationOptions = ['初中及以下', '高中', '大专', '本科', '硕士', '博士及以上'];
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '学历',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: DropdownButton<String>(
        value: _selectedEducation,
        hint: const Text('请选择学历'),
        isExpanded: true,
        underline: Container(),
        items: educationOptions.map((education) {
          return DropdownMenuItem(
            value: education,
            child: Text(education),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selectedEducation = value;
          });
        },
      ),
    );
  }

  Widget _buildSchoolField() {
    return TextFormField(
      controller: _schoolController,
      decoration: const InputDecoration(
        labelText: '毕业院校',
        hintText: '请输入毕业院校',
      ),
    );
  }

  Widget _buildMajorField() {
    return TextFormField(
      controller: _majorController,
      decoration: const InputDecoration(
        labelText: '专业',
        hintText: '请输入专业',
      ),
    );
  }
}
