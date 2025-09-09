import 'package:hive/hive.dart';

import 'chat_message.dart';

part 'chat.g.dart';

@HiveType(typeId: 2)
class Chat extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<ChatMessage> messages;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime lastMessageTime;

  @HiveField(5)
  final String? avatarUrl;

  @HiveField(6)
  final bool isGroupChat;

  @HiveField(7)
  final bool isArchived;

  Chat({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.lastMessageTime,
    this.avatarUrl,
    this.isGroupChat = false,
    this.isArchived = false,
  });

  Chat copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastMessageTime,
    String? avatarUrl,
    bool? isGroupChat,
    bool? isArchived,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGroupChat: isGroupChat ?? this.isGroupChat,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  String get lastMessage {
    if (messages.isEmpty) return '';
    return messages.last.content;
  }

  int get unreadCount {
    return messages
        .where((msg) => !msg.isFromUser && msg.status != MessageStatus.read)
        .length;
  }
}
