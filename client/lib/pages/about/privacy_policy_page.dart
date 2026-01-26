import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          '隐私政策',
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
              const Text(
                'HiTutor 好会帮隐私政策',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '更新日期：2026年1月26日',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection('引言',
                  'HiTutor好会帮（以下简称"我们"或"本平台"）非常重视用户的隐私保护。本隐私政策旨在向您说明我们如何收集、使用、存储和保护您的个人信息。使用本平台家教信息服务即表示您已阅读、理解并同意本隐私政策的所有内容。如果您不同意本隐私政策的任何内容，请立即停止使用本平台家教信息服务。'),
              const SizedBox(height: 16),
              _buildSection('一、信息收集',
                  '我们可能收集您的个人信息，包括但不限于注册信息（如用户名、手机号、邮箱等）、个人资料信息（如姓名、头像、教育背景等）、使用信息（如登录时间、操作记录、浏览记录等）、设备信息（如设备型号、操作系统、IP地址等）、位置信息（在您授权后收集）、交易信息、聊天记录（您在平台内的所有聊天内容）以及您在使用本平台家教信息服务过程中产生的其他相关信息。我们收集这些信息的目的是为了提供和改进家教信息服务，验证用户身份，防止欺诈行为，保障账户安全，进行数据分析以优化用户体验，维护平台秩序和安全。'),
              const SizedBox(height: 16),
              _buildSection('二、信息使用',
                  '我们使用收集的信息用于提供家教信息服务，改善用户体验，发送家教通知，进行数据分析，防止欺诈和违法行为，处理用户投诉和纠纷，执行平台规则。未经您同意，我们不会将您的个人信息用于其他目的。我们不会将您的个人信息用于商业推广，除非获得您的明确同意。我们承诺仅在实现收集目的所必需的范围内使用您的个人信息，不会超出合理范围使用。'),
              const SizedBox(height: 16),
              _buildSection('三、信息共享',
                  '我们不会向第三方出售您的个人信息。在以下情况下，我们可能共享您的信息：获得您的明确同意；法律法规要求；保护您或他人的合法权益；与家教信息对接方合作（仅限必要信息）；为执行家教信息对接协议而需要共享；配合公安机关调查。我们会要求第三方对您的信息进行保密保护。如您涉嫌违法犯罪，我们将配合公安机关提供相关信息。'),
              const SizedBox(height: 16),
              _buildSection('四、信息存储和安全',
                  '我们采用行业标准的安全措施保护您的信息，包括数据加密、访问控制、安全审计、定期安全评估等。您的信息存储在安全的服务器上，访问受到严格限制。我们会定期审查安全措施，确保信息安全。您的信息存储期限为使用本平台期间及终止使用后合理时间内。终止使用后，我们有权保留您的信息用于法律纠纷处理、证据保存等目的。尽管我们采取了安全措施，但互联网传输仍存在风险，您应自行承担信息传输的风险。如发生数据泄露，我们会及时通知您并采取补救措施。您应妥善保管账户信息，因您保管不善导致的损失，本平台不承担责任。'),
              const SizedBox(height: 16),
              _buildSection('五、Cookie和类似技术',
                  '我们使用Cookie和类似技术来改善用户体验。Cookie是存储在您设备上的小型文本文件，用于记住您的偏好设置、保持登录状态、分析用户行为等。您可以通过浏览器设置禁用Cookie，但这可能影响部分功能的使用。我们使用Cookie的目的包括保持用户登录状态、记住用户偏好设置、分析用户行为以改善家教信息服务。'),
              const SizedBox(height: 16),
              _buildSection('六、用户权利',
                  '您有权查看和修改您的个人信息，删除账户（需符合平台规定），撤销授权，投诉和举报，要求获取个人信息副本，要求删除个人信息（需符合平台规定）。您可以通过设置页面行使上述权利。我们会在合理时间内处理您的请求。您删除账户后，我们有权保留您的信息用于法律纠纷处理、证据保存等目的。'),
              const SizedBox(height: 16),
              _buildSection('七、儿童隐私',
                  '我们不向13岁以下儿童提供家教信息服务。如果我们发现收集了13岁以下儿童的信息，我们会立即删除。家长或监护人有权要求删除其未成年子女的个人信息。您应确保您使用本平台的行为符合当地法律法规。'),
              const SizedBox(height: 16),
              _buildSection('八、政策更新',
                  '我们可能会不时更新本隐私政策。更新后的政策将在平台上公布。继续使用本平台即视为您同意更新后的政策。重大更新时，我们会通过邮件或其他方式通知您。如您不同意更新后的政策，应立即停止使用本平台家教信息服务。'),
              const SizedBox(height: 16),
              _buildSection('九、联系我们',
                  '如果您对本隐私政策有任何疑问或建议，或需要行使您的权利，请通过以下方式联系我们：\n\n开发者：杨圣洲\n邮箱：YangSZ03@Foxmail.com\n联系地址：江西科技师范大学红角洲校区\n\n我们会在收到您的请求后尽快回复。'),
              const SizedBox(height: 24),
              const Text(
                '感谢您信任HiTutor好会帮！',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
