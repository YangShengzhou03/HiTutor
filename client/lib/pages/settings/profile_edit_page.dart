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
  
  String? _gender;
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
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    _usernameController.text = user.username;
    _gender = user.gender ?? 'male';
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
      };

      await ApiService.updateProfile(userId.toString(), profileData);

      if (!mounted) return;

      
      final updatedUser = await AuthService.getCurrentUserWithUserId(userId);
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
                user?.username.isNotEmpty == true ? user!.username[0] : 'U',
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
      maxLength: 6,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入用户名';
        }
        if (value.trim().length < 3) {
          return '用户名长度必须在3-6个字之间';
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
}
