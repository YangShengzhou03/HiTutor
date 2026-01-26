import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/location_picker_page.dart';
import '../../models/tutor_model.dart';

class PublishTutorServicePage extends StatefulWidget {
  const PublishTutorServicePage({super.key});

  @override
  State<PublishTutorServicePage> createState() => _PublishTutorServicePageState();
}

class _PublishTutorServicePageState extends State<PublishTutorServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _hourlyRateController = TextEditingController(text: '100');
  final _descriptionController = TextEditingController();
  final _availableTimeController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedSubjectId;
  String _selectedSubjectName = '';
  bool _isLoading = false;
  double? _selectedLatitude;
  double? _selectedLongitude;
  GradeLevel? _selectedGradeLevel;
  
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _descriptionController.dispose();
    _availableTimeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    try {
      final response = await ApiService.getActiveSubjects();
      
      if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          if (data is List) {
            setState(() {
              _subjects = List<Map<String, dynamic>>.from(data.cast());
            });
          }
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载科目失败: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择科目')),
      );
      return;
    }

    if (_selectedGradeLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择目标年级')),
      );
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

      final serviceData = {
        'userId': userId,
        'subjectId': int.parse(_selectedSubjectId!),
        'subjectName': _selectedSubjectName,
        'hourlyRate': _hourlyRateController.text.trim(),
        'address': _addressController.text.trim(),
        'latitude': (_selectedLatitude ?? 39.9042).toString(),
        'longitude': (_selectedLongitude ?? 116.4074).toString(),
        'description': _descriptionController.text.trim(),
        'availableTime': _availableTimeController.text.trim(),
        'targetGradeLevels': _selectedGradeLevel!.id.toString(),
        'status': 'available',
      };

      final response = await ApiService.createService(serviceData);

      if (!mounted) return;

      if (response['success'] == true || response['id'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布成功')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(response['message'] ?? '发布失败');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发布失败: ${e.toString()}')),
      );
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textPrimary,
        ),
        title: const Text(
          '发布家教信息',
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('基本信息'),
                  const SizedBox(height: 12),
                  _buildSubjectSelector(),
                  const SizedBox(height: 16),
                  _buildGradeLevelSelector(),
                  const SizedBox(height: 16),
                  _buildHourlyRateField(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('教学信息'),
                  const SizedBox(height: 12),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildAvailableTimeField(),
                  const SizedBox(height: 16),
                  _buildAddressField(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
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
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedSubjectId,
      decoration: const InputDecoration(
        labelText: '教授科目',
        hintText: '请选择教授科目',
      ),
      items: _subjects.map((subject) {
        return DropdownMenuItem<String>(
          value: subject['id'].toString(),
          child: Text(subject['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubjectId = value;
          _selectedSubjectName = _subjects
              .firstWhere((s) => s['id'].toString() == value)['name'];
        });
      },
      validator: (value) => value == null ? '请选择教授科目' : null,
    );
  }

  Widget _buildGradeLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '目标年级',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GradeLevel.allGradeLevels.map((gradeLevel) {
            final isSelected = _selectedGradeLevel?.id == gradeLevel.id;
            return ChoiceChip(
              label: Text(gradeLevel.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedGradeLevel = gradeLevel;
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHourlyRateField() {
    return TextFormField(
      controller: _hourlyRateController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: '时薪（元/小时）',
        hintText: '请输入时薪',
        suffixText: '元/小时',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入时薪';
        }
        final rate = double.tryParse(value);
        if (rate == null || rate <= 0) {
          return '请输入有效的时薪';
        }
        if (rate > 500) {
          return '时薪不能超过500元/小时';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: '说点什么',
        hintText: '请输入其他说明信息...',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入说明信息';
        }
        return null;
      },
    );
  }

  Widget _buildAvailableTimeField() {
    return TextFormField(
      controller: _availableTimeController,
      decoration: const InputDecoration(
        labelText: '可授课时间',
        hintText: '例如：周末全天、工作日晚上',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入可授课时间';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      readOnly: true,
      onTap: _selectLocation,
      decoration: const InputDecoration(
        labelText: '您的地址',
        hintText: '请选择您的地址',
        prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryColor),
        suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请选择您的地址';
        }
        return null;
      },
    );
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialAddress: _addressController.text,
          initialLatitude: _selectedLatitude,
          initialLongitude: _selectedLongitude,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _addressController.text = result['address'];
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
      });
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitService,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('发布家教信息'),
      ),
    );
  }
}
