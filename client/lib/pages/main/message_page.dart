import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/message_provider.dart';
import '../../models/message_model.dart';
import '../../routes.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  static const _paddingH16 = EdgeInsets.symmetric(horizontal: 16);
  static const _padding12 = EdgeInsets.all(12);
  static final _borderRadius12 = BorderRadius.circular(12);
  static final _borderRadius24 = BorderRadius.circular(24);
  static final _borderRadius20 = BorderRadius.circular(20);

  @override
  void initState() {
    super.initState();
    
    Provider.of<MessageProvider>(context, listen: false).getConversations();
  }

  
  void _handleMessageTap(ChatSession conversation) {
    
    if (conversation.unreadCount > 0) {
      Provider.of<MessageProvider>(context, listen: false).markAsRead(conversation.id);
    }
    
    
    final otherUserId = conversation.otherUser.id;
    final otherUserName = conversation.otherUser.name;
    
    Navigator.pushNamed(
      context,
      Routes.chatDetail,
      arguments: {
        'conversationId': conversation.id,
        'otherUserId': otherUserId,
        'otherUserName': otherUserName,
      },
    );
  }

  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  
  Color _getConversationColor(ChatSession conversation) {
    if (conversation.type == 'system') {
      return const Color(0xFF64748B);
    } else if (conversation.type == 'ai') {
      return AppTheme.primaryColor;
    } else if (conversation.name.contains('老师')) {
      return const Color(0xFF10B981);
    } else {
      return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMessageList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<MessageProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 44,
          padding: _paddingH16,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '消息',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (provider.totalUnreadCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: _borderRadius20,
                        ),
                        child: Text(
                          provider.totalUnreadCount.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    return Consumer<MessageProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.errorMessage.isNotEmpty) {
          return _buildErrorState(provider.errorMessage);
        }

        if (provider.conversations.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: provider.conversations.length,
          itemBuilder: (context, index) {
            final conversation = provider.conversations[index];
            return _buildMessageItem(conversation);
          },
        );
      },
    );
  }

  
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          SizedBox(height: 16),
          Text(
            '正在加载消息...',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          const Text(
            '加载失败',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<MessageProvider>(context, listen: false).getConversations();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppTheme.textTertiary),
          SizedBox(height: 16),
          Text(
            '暂无消息',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatSession conversation) {
    final hasUnread = conversation.unreadCount > 0;
    final accentColor = _getConversationColor(conversation);
    final formattedTime = _formatTime(conversation.updatedAt);

    return GestureDetector(
      onTap: () => _handleMessageTap(conversation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: _padding12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _borderRadius12,
          boxShadow: const [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: _borderRadius24,
                  ),
                  child: Center(
                    child: Text(
                      conversation.name.isNotEmpty ? conversation.name[0] : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                conversation.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (conversation.otherUser.gender != null && conversation.otherUser.gender!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  conversation.otherUser.gender == 'male' ? '♂' : '♀',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: conversation.otherUser.gender == 'male' ? AppTheme.maleColor : AppTheme.femaleColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasUnread)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: _borderRadius20,
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
