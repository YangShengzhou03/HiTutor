import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

class MessageProvider with ChangeNotifier {
  List<ChatSession> _conversations = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalUnreadCount = 0;
  String? _currentUserId;

  List<ChatSession> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalUnreadCount => _totalUnreadCount;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  
  Future<void> getConversations() async {
    if (_currentUserId == null) return;
    
    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await ApiService.getConversations(_currentUserId!);
      
      _conversations = (response['data'] as List)
          .map((item) => ChatSession.fromJson(item))
          .toList();

      
      _totalUnreadCount = _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> markAsRead(String conversationId) async {
    if (_currentUserId == null) return;
    
    try {
      await ApiService.markAsRead(conversationId, _currentUserId!);
      
      
      final index = _conversations.indexWhere((conv) => conv.id == conversationId);
      if (index != -1) {
        _totalUnreadCount -= _conversations[index].unreadCount;
        
        final updatedSession = ChatSession(
          id: _conversations[index].id,
          otherUser: _conversations[index].otherUser,
          lastMessage: _conversations[index].lastMessage,
          unreadCount: 0,
          updatedAt: _conversations[index].updatedAt,
        );
        _conversations[index] = updatedSession;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '标记已读失败: ${e.toString()}';
    }
  }

  
  Future<void> sendMessage(String conversationId, String content, String receiverId) async {
    if (_currentUserId == null) return;
    
    try {
      final response = await ApiService.sendMessage(
        conversationId,
        _currentUserId!,
        receiverId,
        content,
      );
      
      final newMessage = Message.fromJson(response['data']);
      
      
      final index = _conversations.indexWhere((conv) => conv.id == conversationId);
      if (index != -1) {
        
        final newLastMessage = Message(
          id: newMessage.id,
          sender: newMessage.sender,
          receiver: newMessage.receiver,
          content: newMessage.content,
          type: newMessage.type,
          isRead: newMessage.isRead,
          createdAt: newMessage.createdAt,
        );
        
        
        final updatedSession = ChatSession(
          id: _conversations[index].id,
          otherUser: _conversations[index].otherUser,
          lastMessage: newLastMessage,
          unreadCount: _conversations[index].unreadCount, 
          updatedAt: DateTime.now(),
        );
        _conversations[index] = updatedSession;
        notifyListeners();
      }
    } catch (e) {
      
      rethrow;
    }
  }

  
  Future<void> deleteConversation(String conversationId) async {
    try {
      
      
      
      
      final index = _conversations.indexWhere((conv) => conv.id == conversationId);
      if (index != -1) {
        _totalUnreadCount -= _conversations[index].unreadCount;
        _conversations.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      
      rethrow;
    }
  }

  
  Future<void> refresh() async {
    await getConversations();
  }
}
