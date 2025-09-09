import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/chat.dart';
import '../../../../shared/models/chat_message.dart';
import '../../../../shared/providers/chat_provider.dart';
import '../../../../shared/widgets/chat_layout.dart';
import '../../../../shared/widgets/chat_sidebar.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage({super.key});

  @override
  ConsumerState<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends ConsumerState<ChatHomePage> {
  Chat? _selectedChat;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ChatLayoutState> _chatLayoutKey =
      GlobalKey<ChatLayoutState>();

  @override
  void initState() {
    super.initState();
    // İlk sohbeti otomatik seç
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chats = ref.read(chatsProvider);
      final activeChats = chats.where((chat) => !chat.isArchived).toList();
      if (activeChats.isNotEmpty) {
        setState(() {
          _selectedChat = activeChats.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChatSelected(Chat chat) {
    setState(() {
      _selectedChat = chat;
    });
    // Mesajları okundu olarak işaretle
    ref.read(chatsProvider.notifier).markMessagesAsRead(chat.id);

    // Sohbet değiştiğinde en alta scroll yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _closeSidebar() {
    // GlobalKey ile ChatLayout'tan drawer'ı kapat
    ChatLayoutState.closeDrawerFromKey(_chatLayoutKey);

    // Drawer kapatıldığında da en alta scroll yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendMessage() async {
    if (_selectedChat == null) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    // Gelişmiş AI chat metodu kullan
    await ref
        .read(chatsProvider.notifier)
        .sendMessageWithHistory(_selectedChat!.id, message);

    // Mesaj gönderildikten sonra en alta scroll yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatsProvider);
    final selectedChat = chats.firstWhere(
      (c) => c.id == _selectedChat?.id,
      orElse: () =>
          _selectedChat ??
          Chat(
            id: '',
            title: '',
            messages: [],
            createdAt: DateTime.now(),
            lastMessageTime: DateTime.now(),
          ),
    );

    // Mesajlar değiştiğinde otomatik scroll yap
    ref.listen<List<Chat>>(chatsProvider, (previous, next) {
      if (_selectedChat != null) {
        final currentChat = next.firstWhere(
          (chat) => chat.id == _selectedChat!.id,
          orElse: () => _selectedChat!,
        );

        // Yeni mesaj geldiğinde scroll yap
        if (previous != null) {
          final previousChat = previous.firstWhere(
            (chat) => chat.id == _selectedChat!.id,
            orElse: () => Chat(
              id: '',
              title: '',
              messages: [],
              createdAt: DateTime.now(),
              lastMessageTime: DateTime.now(),
            ),
          );

          if (currentChat.messages.length > previousChat.messages.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
        }
      }
    });

    return ChatLayout(
      key: _chatLayoutKey,
      sidebar: ChatSidebar(
        selectedChat: selectedChat,
        onChatSelected: _onChatSelected,
        onCloseDrawer: _closeSidebar,
      ),
      mainContent: _buildMainContent(selectedChat),
      onToggleSidebar: () {
        // Sidebar toggle callback - mobilde drawer açma/kapama
      },
    );
  }

  Widget _buildMainContent(Chat chat) {
    if (chat.id.isEmpty) {
      return _buildWelcomeScreen();
    }

    return SafeArea(
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderLight.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGradientStart,
                  child: chat.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            chat.avatarUrl!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildAvatarFallback(chat),
                          ),
                        )
                      : _buildAvatarFallback(chat),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.title.isNotEmpty ? chat.title : 'Yeni Sohbet',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Çevrimiçi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: chat.messages.isEmpty
                ? _buildEmptyChat(chat)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.messages.length,
                    reverse: false, // Normal sıralama (eski mesajlar üstte)
                    addAutomaticKeepAlives: false, // Performans için
                    itemBuilder: (context, index) {
                      final message = chat.messages[index];
                      return MessageBubble(
                        message: message,
                        showTime:
                            index == chat.messages.length - 1 ||
                            _shouldShowTime(chat.messages, index),
                      );
                    },
                  ),
          ),

          // Chat input
          ChatInput(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusExtraLarge,
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Chat\'e Hoş Geldiniz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Yeni bir sohbet başlatmak için aşağıdaki butona tıklayın',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () => _createNewChat(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Yeni Sohbet Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewChat() async {
    final newChat = await ref
        .read(chatsProvider.notifier)
        .createNewChatAndCloseDriver();
    setState(() {
      _selectedChat = newChat;
    });
  }

  Widget _buildEmptyChat(Chat chat) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            chat.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlk mesajınızı gönderin',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(Chat chat) {
    return Center(
      child: Text(
        chat.title.isNotEmpty ? chat.title[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  bool _shouldShowTime(List<ChatMessage> messages, int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final difference = currentMessage.timestamp.difference(
      previousMessage.timestamp,
    );
    return difference.inMinutes > 5;
  }
}
