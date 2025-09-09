import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final bool isFromUser;

  @HiveField(4)
  final String? senderName;

  @HiveField(5)
  final MessageStatus status;

  @HiveField(6)
  final Map<String, dynamic>? contextInfo;

  @HiveField(7)
  final List<Map<String, dynamic>>? sources;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isFromUser,
    this.senderName,
    this.status = MessageStatus.sent,
    this.contextInfo,
    this.sources,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    bool? isFromUser,
    String? senderName,
    MessageStatus? status,
    Map<String, dynamic>? contextInfo,
    List<Map<String, dynamic>>? sources,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isFromUser: isFromUser ?? this.isFromUser,
      senderName: senderName ?? this.senderName,
      status: status ?? this.status,
      contextInfo: contextInfo ?? this.contextInfo,
      sources: sources ?? this.sources,
    );
  }
}

@HiveType(typeId: 1)
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  sent,
  @HiveField(2)
  delivered,
  @HiveField(3)
  read,
  @HiveField(4)
  failed,
  @HiveField(5)
  error,
}
