import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class TutorResumePage extends StatefulWidget {
  const TutorResumePage({super.key});

  @override
  State<TutorResumePage> createState() => _TutorResumePageState();
}

class _TutorResumePageState extends State<TutorResumePage> {
  final _formKey = GlobalKey<FormState>();
  final _teachingExperienceController = TextEditingController();
  final _teachingStyleController = TextEditingController();
  final _specialtiesController = TextEditingController();
  final _achievementsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadResume();
  }

  Future<void> _loadResume() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      return;
    }

    try {
      final response = await ApiService.getTutorResume(userId);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        setState(() {
          _teachingExperienceController.text = data['teachingExperience']?.toString() ?? '';
          _teachingStyleController.text = data['teachingStyle'] ?? '';
          _specialtiesController.text = data['specialties'] ?? '';
          _achievementsController.text = data['achievements'] ?? '';
        });
      }
    } catch (_) {
    }
  }

  @override
  void dispose() {
    _teachingExperienceController.dispose();
    _teachingStyleController.dispose();
    _specialtiesController.dispose();
    _achievementsController.dispose();
    super.dispose();
  }

  Future<void> _saveResume() async {
    if (!_formKey.currentState!.validate()) {
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
      final expText = _teachingExperienceController.text;
      final expMatch = RegExp(r'^([1-9]\d?|90)年$').firstMatch(expText);
      final expInt = expMatch?.group(1) != null 
          ? int.tryParse(expMatch!.group(1)!) ?? 0 
          : 90;

      await ApiService.saveTutorResume({
        'userId': userId,
        'teachingExperience': expInt,
        'teachingStyle': _teachingStyleController.text,
        'specialties': _specialtiesController.text,
        'achievements': _achievementsController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('简历保存成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('家教简历'),
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
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveResume,
              child: const Text(
                '保存',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('教学经验'),
                const SizedBox(height: 12),
                _buildTextField(
                  _teachingExperienceController,
                  '教学年限',
                  '请输入教学年限（如：5年）',
                  Icons.access_time_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入教学年限';
                    }
                    final regex = RegExp(r'^([1-9]\d?|90)年$');
                    if (!regex.hasMatch(value)) {
                      return '请输入正确的格式（如：5年），范围0-90年';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _teachingStyleController,
                  '教学风格',
                  '请输入教学风格（如：耐心细致、互动式教学）',
                  Icons.psychology_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入教学风格';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('擅长科目'),
                const SizedBox(height: 12),
                _buildTextField(
                  _specialtiesController,
                  '擅长科目',
                  '请输入擅长科目（如：数学、物理、化学）',
                  Icons.menu_book_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入擅长科目';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('教学成就'),
                const SizedBox(height: 12),
                _buildTextField(
                  _achievementsController,
                  '教学成就',
                  '请输入教学成就（如：帮助学生提高成绩、获得优秀家教称号）',
                  Icons.emoji_events_rounded,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入教学成就';
                    }
                    return null;
                  },
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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
}
