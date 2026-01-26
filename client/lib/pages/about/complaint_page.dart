import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ComplaintPage extends StatefulWidget {
  final String? targetUserId;

  const ComplaintPage({
    super.key,
    this.targetUserId,
  });

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _targetIdController = TextEditingController();
  
  String _selectedCategory = '';
  String _selectedType = '';
  bool _isSubmitting = false;

  final List<String> _categories = [
    '家教信息',
    '预约问题',
    '账号安全',
    '其他问题'
  ];

  final Map<String, List<String>> _typesByCategory = {
    '家教信息': ['教学质量', '服务态度', '迟到早退', '其他'],
    '预约问题': ['取消预约', '时间冲突', '未按时上课', '其他'],
    '账号安全': ['账号被盗', '密码泄露', '虚假信息', '其他'],
    '其他问题': ['系统bug', '功能建议', '其他']
  };

  @override
  void initState() {
    super.initState();
    if (widget.targetUserId != null) {
      _targetIdController.text = widget.targetUserId!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _targetIdController.dispose();
    super.dispose();
  }

  void _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择举报分类')),
      );
      return;
    }

    if (_selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择举报类型')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final Map<String, dynamic> complaintData = {
        'categoryName': _selectedCategory,
        'typeText': _selectedType,
        'description': _descriptionController.text,
      };

      if (_targetIdController.text.isNotEmpty) {
        complaintData['targetUserId'] = _targetIdController.text;
      }

      await ApiService.createComplaint(complaintData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('举报提交成功')),
        );
        Navigator.pop(context);
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
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('举报投诉'),
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
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('举报分类'),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('举报类型'),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('举报对象'),
              const SizedBox(height: 12),
              _buildTargetField(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('举报说明'),
              const SizedBox(height: 12),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              
              _buildSubmitButton(),
            ],
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
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          hint: const Text('请选择举报分类'),
          isExpanded: true,
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
              _selectedType = '';
            });
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    if (_selectedCategory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '请先选择举报分类',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final types = _typesByCategory[_selectedCategory] ?? [];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedType = type;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTargetField() {
    final hasPresetTarget = widget.targetUserId != null;
    
    return TextFormField(
      controller: _targetIdController,
      keyboardType: TextInputType.text,
      readOnly: hasPresetTarget,
      decoration: InputDecoration(
        labelText: '被投诉用户ID',
        hintText: '请输入被投诉用户ID',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: hasPresetTarget ? Colors.grey.shade100 : Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入被投诉用户ID';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: '详细说明',
        hintText: '请详细描述您遇到的问题',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入举报说明';
        }
        if (value.length < 10) {
          return '举报说明至少需要10个字符';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitComplaint,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                '提交举报',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}