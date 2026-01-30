import 'package:flutter/material.dart';

class ApplicationDetailPage extends StatefulWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailPage({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  @override
  Widget build(BuildContext context) {
    final application = widget.application;
    final status = application['status'] ?? 'pending';

    Color statusColor = Colors.grey;
    String statusText = '等待筛选';
    if (status == 'accepted') {
      statusColor = Colors.green;
      statusText = '已接受';
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusText = '已拒绝';
    } else if (status == 'cancelled') {
      statusColor = Colors.orange;
      statusText = '已取消';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('报名详情'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '申请人信息',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('姓名:', application['applicantName'] ?? ''),
                    const SizedBox(height: 8),
                    _buildInfoRow('电话:', application['applicantPhone'] ?? ''),
                    const SizedBox(height: 8),
                    _buildInfoRow('报名时间:', _formatDateTime(application['createdAt'] ?? application['createTime'])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '申请留言',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      application['message'] ?? '无',
                      style: const TextStyle(fontSize: 14),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '未知';
    
    String dateTimeStr = dateTime.toString();
    
    DateTime? parsedDate;
    
    if (dateTimeStr.contains('T')) {
      parsedDate = DateTime.tryParse(dateTimeStr);
    } else if (dateTimeStr.contains(' ')) {
      final parts = dateTimeStr.split(' ');
      if (parts.length >= 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');
        if (dateParts.length == 3 && timeParts.length >= 3) {
          try {
            parsedDate = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
              int.parse(timeParts[2]),
            );
          } catch (e) {
            return '未知';
          }
        }
      }
    } else {
      parsedDate = DateTime.tryParse(dateTimeStr);
    }
    
    if (parsedDate == null) return '未知';
    
    return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
  }
}