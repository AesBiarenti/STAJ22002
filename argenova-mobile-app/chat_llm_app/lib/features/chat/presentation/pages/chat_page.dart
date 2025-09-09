import 'package:chat_llm_app/shared/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/chat.dart';
import '../../../../shared/models/chat_message.dart';
import '../../../../shared/providers/chat_provider.dart';
import '../../../../shared/services/ai_service.dart';
import '../../../../shared/widgets/custom_popup_menu.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  final Chat chat;

  const ChatPage({super.key, required this.chat});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // Arama özelliği için state
  bool _isSearchMode = false;
  String _searchQuery = '';
  List<ChatMessage> _filteredMessages = [];
  int _currentSearchIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      // Mesajları okundu olarak işaretle
      _markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Mesajları okundu olarak işaretle
  void _markMessagesAsRead() {
    ref.read(chatsProvider.notifier).markMessagesAsRead(widget.chat.id);
  }

  // Arama fonksiyonları
  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _searchQuery = '';
        _filteredMessages = [];
        _currentSearchIndex = -1;
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMessages = [];
        _currentSearchIndex = -1;
      } else {
        _filteredMessages = widget.chat.messages
            .where(
              (message) =>
                  message.content.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
        _currentSearchIndex = _filteredMessages.isNotEmpty ? 0 : -1;
      }
    });
  }

  void _nextSearchResult() {
    if (_filteredMessages.isEmpty) return;

    setState(() {
      _currentSearchIndex =
          (_currentSearchIndex + 1) % _filteredMessages.length;
    });

    _scrollToMessage(_filteredMessages[_currentSearchIndex]);
  }

  void _previousSearchResult() {
    if (_filteredMessages.isEmpty) return;

    setState(() {
      _currentSearchIndex = _currentSearchIndex <= 0
          ? _filteredMessages.length - 1
          : _currentSearchIndex - 1;
    });

    _scrollToMessage(_filteredMessages[_currentSearchIndex]);
  }

  void _scrollToMessage(ChatMessage message) {
    final messageIndex = widget.chat.messages.indexOf(message);
    if (messageIndex != -1 && _scrollController.hasClients) {
      _scrollController.animateTo(
        messageIndex * 80.0, // Yaklaşık mesaj yüksekliği
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      timestamp: DateTime.now(),
      isFromUser: true,
      status: MessageStatus.sent,
    );

    ref.read(chatsProvider.notifier).addMessage(widget.chat.id, chatMessage);
    _messageController.clear();

    // AI yanıtı al
    try {
      final response = await AIService.queryAI(message);
      final aiResponse = AIResponse.fromJson(response);

      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: aiResponse.response,
        timestamp: DateTime.now(),
        isFromUser: false,
        senderName: 'AI Asistan',
        status: MessageStatus.sent,
      );

      ref.read(chatsProvider.notifier).addMessage(widget.chat.id, aiMessage);
    } catch (e) {
      // Hata durumunda fallback yanıt
      final errorMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content:
            'Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.',
        timestamp: DateTime.now(),
        isFromUser: false,
        senderName: 'AI Asistan',
        status: MessageStatus.sent,
      );

      ref.read(chatsProvider.notifier).addMessage(widget.chat.id, errorMessage);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatsProvider);
    final chat = chats.firstWhere(
      (c) => c.id == widget.chat.id,
      orElse: () => widget.chat, // Eğer chat bulunamazsa widget.chat'i kullan
    );

    return GradientScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: chat.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        chat.avatarUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildAvatarFallback(context, chat),
                      ),
                    )
                  : _buildAvatarFallback(context, chat),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Çevrimiçi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CustomPopupMenu(
            items: [
              CustomPopupMenuItem(
                title: _isSearchMode ? 'Aramayı Kapat' : 'Ara',
                icon: _isSearchMode ? Icons.close : Icons.search,
                iconColor: AppTheme.accentBlue,
                onTap: _toggleSearchMode,
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama bar'ı
          if (_isSearchMode) _buildSearchBar(),
          Expanded(
            child: chat.messages.isEmpty
                ? _buildEmptyChat(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) {
                      final message = chat.messages[index];
                      final isHighlighted =
                          _searchQuery.isNotEmpty &&
                          message.content.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) &&
                          _filteredMessages.contains(message);

                      return MessageBubble(
                        message: message,
                        showTime:
                            index == chat.messages.length - 1 ||
                            _shouldShowTime(chat.messages, index),
                        isHighlighted: isHighlighted,
                        isCurrentSearchResult:
                            message == _filteredMessages.isNotEmpty &&
                                _currentSearchIndex >= 0
                            ? _filteredMessages[_currentSearchIndex]
                            : null,
                      );
                    },
                  ),
          ),
          ChatInput(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(BuildContext context, Chat chat) {
    return Text(
      chat.title.isNotEmpty ? chat.title[0].toUpperCase() : '?',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildEmptyChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Sohbet başlatın',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Mesaj göndermek için aşağıdaki kutuya yazın',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Arama input'u
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Mesajlarda ara...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.accentBlue,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _performSearch(''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: _performSearch,
            ),
          ),
          // Arama sonuçları bilgisi ve navigasyon
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Sonuç sayısı
                Text(
                  '${_filteredMessages.length} sonuç bulundu',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                // Navigasyon butonları
                if (_filteredMessages.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: _previousSearchResult,
                    tooltip: 'Önceki sonuç',
                  ),
                  Text(
                    '${_currentSearchIndex + 1}/${_filteredMessages.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: _nextSearchResult,
                    tooltip: 'Sonraki sonuç',
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
