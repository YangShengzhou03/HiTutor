import 'user_model.dart';

class Message {
  final String id;
  final User sender;
  final User receiver;
  final String content;
  final MessageType type;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      sender: User.fromJson(json['sender'] ?? {}),
      receiver: User.fromJson(json['receiver'] ?? {}),
      content: json['content']?.toString() ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      isRead: json['isRead'] == true || json['isRead'] == 1,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

enum MessageType {
  text,      
  image,     
  voice,     
  system     
}

class ChatSession {
  final String id;
  final User otherUser;
  final Message lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final String type;
  final String name;

  ChatSession({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
    this.type = 'user',
    String? name,
  }) : name = name ?? otherUser.name;

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id']?.toString() ?? '',
      otherUser: User.fromJson(json['otherUser'] ?? {}),
      lastMessage: Message.fromJson(json['lastMessage'] ?? {}),
      unreadCount: json['unreadCount'] is int ? json['unreadCount'] : int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: json['type']?.toString() ?? 'user',
      name: json['name']?.toString(),
    );
  }
}
