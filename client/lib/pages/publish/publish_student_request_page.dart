import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/location_picker_page.dart';

class PublishStudentRequestPage extends StatefulWidget {
  const PublishStudentRequestPage({super.key});

  @override
  State<PublishStudentRequestPage> createState() => _PublishStudentRequestPageState();
}

class _PublishStudentRequestPageState extends State<PublishStudentRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _childNameController = TextEditingController();
  String _selectedGrade = '';
  final _requirementsController = TextEditingController();
  final _availableTimeController = TextEditingController();
  final _addressController = TextEditingController();  
  String? _selectedSubjectId;
  String _selectedSubjectName = '';
  double _minHourlyRate = 50;
  double _maxHourlyRate = 200;
  bool _isLoading = false;
  double? _selectedLatitude;
  double? _selectedLongitude;
  
  List<Map<String, dynamic>> _subjects = [];
  final List<String> _grades = [
    '学前', '一年级', '二年级', '三年级', '四年级', '五年级', '六年级',
    '七年级', '八年级', '九年级', '高一', '高二', '高三'
  ];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _requirementsController.dispose();
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

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择科目')),
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

      final requestData = {
        'userId': userId,
        'childName': _childNameController.text.trim(),
        'childGrade': _selectedGrade,
        'subjectId': int.parse(_selectedSubjectId!),
        'subjectName': _selectedSubjectName,
        'hourlyRateMin': _minHourlyRate.toString(),
        'hourlyRateMax': _maxHourlyRate.toString(),
        'address': _addressController.text.trim(),
        'latitude': (_selectedLatitude ?? 39.9042).toString(),
        'longitude': (_selectedLongitude ?? 116.4074).toString(),
        'requirements': _requirementsController.text.trim(),
        'availableTime': _availableTimeController.text.trim(),
        'status': 'recruiting',
      };

      final response = await ApiService.createRequest(requestData);

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
          '发布请家教需求',
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
                  _buildChildNameField(),
                  const SizedBox(height: 16),
                  _buildChildGradeField(),
                  const SizedBox(height: 16),
                  _buildSubjectSelector(),
                  const SizedBox(height: 16),
                  _buildHourlyRateSlider(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('教学要求'),
                  const SizedBox(height: 12),
                  _buildRequirementsField(),
                  const SizedBox(height: 16),
                  _buildAvailableTimeField(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('上课地址'),
                  const SizedBox(height: 12),
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

  Widget _buildChildNameField() {
    return TextFormField(
      controller: _childNameController,
      maxLength: 6,
      decoration: const InputDecoration(
        labelText: '孩子称呼',
        hintText: '请输入孩子称呼',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入孩子称呼';
        }
        if (value.length > 6) {
          return '孩子称呼最多6个字';
        }
        return null;
      },
    );
  }

  Widget _buildChildGradeField() {
    return DropdownButtonFormField<String>(
      value: _selectedGrade.isEmpty ? null : _selectedGrade,
      hint: const Text('请选择年级'),
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: '孩子年级',
      ),
      items: _grades.map((String grade) {
        return DropdownMenuItem<String>(
          value: grade,
          child: Text(grade),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGrade = newValue ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请选择年级';
        }
        return null;
      },
    );
  }

  Widget _buildSubjectSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedSubjectId,
      hint: const Text('请选择科目'),
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: '请选择科目',
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请选择科目';
        }
        return null;
      },
    );
  }

  Widget _buildHourlyRateSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '时薪范围',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '¥${_minHourlyRate.toInt()} - ¥${_maxHourlyRate.toInt()}/小时',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveTrackColor: AppTheme.dividerColor,
                  thumbColor: AppTheme.primaryColor,
                  overlayColor: AppTheme.primaryColor.withOpacity(0.1),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: RangeSlider(
                  values: RangeValues(_minHourlyRate, _maxHourlyRate),
                  min: 20,
                  max: 500,
                  divisions: 48,
                  labels: RangeLabels(
                    '¥${_minHourlyRate.toInt()}',
                    '¥${_maxHourlyRate.toInt()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _minHourlyRate = values.start;
                      _maxHourlyRate = values.end;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: TextFormField(
        controller: _requirementsController,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: '教学要求',
          hintText: '请描述您的教学要求，例如：需要提高数学成绩、希望每周上课2次等',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          labelStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '请输入教学要求';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAvailableTimeField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: TextFormField(
        controller: _availableTimeController,
        decoration: const InputDecoration(
          labelText: '可上课时间',
          hintText: '例如：周末上午、工作日晚上',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          labelStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '请输入可上课时间';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      readOnly: true,
      onTap: _selectLocation,
      decoration: const InputDecoration(
        labelText: '上课地址',
        hintText: '请选择您的地址',
        prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryColor),
        suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请选择上课地址';
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
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
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
                '发布需求',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
