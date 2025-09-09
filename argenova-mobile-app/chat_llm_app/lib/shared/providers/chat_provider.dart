import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

final chatsProvider = StateNotifierProvider<ChatNotifier, List<Chat>>((ref) {
  return ChatNotifier();
});

final selectedChatProvider = StateProvider<Chat?>((ref) => null);

class ChatNotifier extends StateNotifier<List<Chat>> {
  ChatNotifier() : super([]) {
    _loadChats();
  }

  static const String _chatsBoxName = 'chats';

  Future<void> _loadChats() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_chatsBoxName)) {
      await Hive.openBox<Chat>(_chatsBoxName);
    }

    final box = Hive.box<Chat>(_chatsBoxName);
    final chats = box.values.toList();
    state = chats;
  }

  Future<void> addChat(Chat chat) async {
    final box = Hive.box<Chat>(_chatsBoxName);
    await box.put(chat.id, chat);
    state = [...state, chat];
  }

  Future<void> updateChat(Chat chat) async {
    final box = Hive.box<Chat>(_chatsBoxName);
    await box.put(chat.id, chat);
    state = state.map((c) => c.id == chat.id ? chat : c).toList();
  }

  Future<void> deleteChat(String chatId) async {
    final box = Hive.box<Chat>(_chatsBoxName);
    await box.delete(chatId);
    state = state.where((chat) => chat.id != chatId).toList();
  }

  Future<void> addMessage(String chatId, ChatMessage message) async {
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) return;

    final chat = state[chatIndex];
    final updatedMessages = [...chat.messages, message];

    // İlk kullanıcı mesajı ise başlığı güncelle
    String newTitle = chat.title;
    print('DEBUG: addMessage - message.isFromUser: ${message.isFromUser}');
    print(
      'DEBUG: addMessage - chat.messages.isEmpty: ${chat.messages.isEmpty}',
    );
    print('DEBUG: addMessage - chat.title.isEmpty: ${chat.title.isEmpty}');
    print('DEBUG: addMessage - chat.title: "${chat.title}"');

    if (message.isFromUser && chat.messages.isEmpty && chat.title.isEmpty) {
      newTitle = _generateTitleFromMessage(message.content);
      print('DEBUG: Updating title in addMessage: "$newTitle"');
    }

    final updatedChat = chat.copyWith(
      messages: updatedMessages,
      lastMessageTime: message.timestamp,
      title: newTitle,
    );

    await updateChat(updatedChat);
  }

  // Gelişmiş AI chat metodu - Chat history desteği
  Future<void> sendMessageWithHistory(String chatId, String message) async {
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) return;

    final chat = state[chatIndex];

    // Kullanıcı mesajını ekle
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isFromUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    await addMessage(chatId, userMessage);

    // AI yanıtı için loading mesajı ekle
    final loadingMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Yanıt hazırlanıyor...',
      isFromUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    await addMessage(chatId, loadingMessage);

    try {
      // Chat history'yi hazırla (son 10 mesaj)
      final recentMessages = chat.messages.take(10).toList();
      final history = recentMessages
          .map(
            (msg) => {
              'role': msg.isFromUser ? 'user' : 'assistant',
              'content': msg.content,
            },
          )
          .toList();

      // AI yanıtı al
      final response = await AIService.queryAIWithHistory(message, history);

      // Sources verisini doğru formata çevir
      List<Map<String, dynamic>>? sources;
      if (response['sources'] != null) {
        final sourcesList = response['sources'] as List<dynamic>;
        sources = sourcesList
            .map((source) => source as Map<String, dynamic>)
            .toList();
      }

      // Loading mesajını güncelle
      final aiMessage = ChatMessage(
        id: loadingMessage.id,
        content: response['success'] == true
            ? response['answer'] ?? 'Yanıt alınamadı'
            : 'Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.',
        isFromUser: false,
        timestamp: DateTime.now(),
        status: response['success'] == true
            ? MessageStatus.sent
            : MessageStatus.error,
        contextInfo: response['context_info'],
        sources: sources,
      );

      await updateMessage(chatId, aiMessage);
    } catch (e) {
      // Hata durumunda loading mesajını güncelle
      final errorMessage = ChatMessage(
        id: loadingMessage.id,
        content: 'Bağlantı hatası: $e',
        isFromUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );

      await updateMessage(chatId, errorMessage);
    }
  }

  // Mesajdan başlık oluştur
  String _generateTitleFromMessage(String message) {
    // Mesajı temizle
    String cleanMessage = message.trim();

    // Boş mesaj kontrolü
    if (cleanMessage.isEmpty) {
      return 'Yeni Sohbet';
    }

    // Soru işareti varsa soru olarak kabul et
    if (cleanMessage.contains('?')) {
      // Soru işaretine kadar al ve kısalt
      String question = cleanMessage.split('?')[0].trim();
      if (question.length > 40) {
        question = '${question.substring(0, 40)}...';
      }
      return question;
    }

    // Çok uzun mesajları kısalt
    if (cleanMessage.length > 40) {
      cleanMessage = '${cleanMessage.substring(0, 40)}...';
    }

    return cleanMessage;
  }

  // Yeni sohbet oluştur ve driver'ı kapat
  Future<Chat> createNewChatAndCloseDriver() async {
    final newChat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '', // Başlık boş bırakılır, ilk mesajdan oluşturulacak
      messages: [],
      createdAt: DateTime.now(),
      lastMessageTime: DateTime.now(),
      isArchived: false,
    );

    await addChat(newChat);

    // Driver'ı kapat (eğer açıksa)
    await _closeDriver();

    return newChat;
  }

  // Driver'ı kapat
  Future<void> _closeDriver() async {
    try {
      // Burada driver kapatma işlemi yapılabilir
      // Örneğin: await driver.quit();
      print('Driver kapatıldı');
    } catch (e) {
      print('Driver kapatma hatası: $e');
    }
  }

  Future<void> updateMessage(String chatId, ChatMessage message) async {
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) return;

    final chat = state[chatIndex];
    final updatedMessages = chat.messages.map((msg) {
      if (msg.id == message.id) {
        return message;
      }
      return msg;
    }).toList();

    final updatedChat = chat.copyWith(messages: updatedMessages);
    await updateChat(updatedChat);
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) return;

    final chat = state[chatIndex];
    final updatedMessages = chat.messages.map((msg) {
      if (!msg.isFromUser && msg.status != MessageStatus.read) {
        return msg.copyWith(status: MessageStatus.read);
      }
      return msg;
    }).toList();

    final updatedChat = chat.copyWith(messages: updatedMessages);
    await updateChat(updatedChat);
  }

  Future<void> archiveChat(String chatId) async {
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) return;

    final chat = state[chatIndex];
    final updatedChat = chat.copyWith(isArchived: true);
    await updateChat(updatedChat);
  }

  Future<void> unarchiveChat(String chatId) async {
    final chatIndex = state.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) return;

    final chat = state[chatIndex];
    final updatedChat = chat.copyWith(isArchived: false);
    await updateChat(updatedChat);
  }
}
