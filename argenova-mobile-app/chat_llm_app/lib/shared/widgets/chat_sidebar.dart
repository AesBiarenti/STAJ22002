import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../features/chat/presentation/widgets/chat_list_item.dart';
import '../../shared/models/chat.dart';
import '../../shared/providers/chat_provider.dart';
import '../widgets/custom_bottom_sheet.dart';
import '../widgets/custom_dialog.dart';

class ChatSidebar extends ConsumerStatefulWidget {
  final Chat? selectedChat;
  final Function(Chat) onChatSelected;
  final VoidCallback? onNewChat;
  final VoidCallback? onSettings;
  final VoidCallback? onCloseDrawer;

  const ChatSidebar({
    super.key,
    this.selectedChat,
    required this.onChatSelected,
    this.onNewChat,
    this.onSettings,
    this.onCloseDrawer,
  });

  @override
  ConsumerState<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends ConsumerState<ChatSidebar> {
  String _searchQuery = '';
  List<Chat> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredChats();
  }

  void _updateFilteredChats() {
    final chats = ref.read(chatsProvider);
    final activeChats = chats.where((chat) => !chat.isArchived).toList();

    // En son sohbet en üstte olacak şekilde sırala
    activeChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    if (_searchQuery.isEmpty) {
      _filteredChats = activeChats;
    } else {
      _filteredChats = activeChats
          .where(
            (chat) =>
                chat.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                chat.lastMessage.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatsProvider);
    final activeChats = chats.where((chat) => !chat.isArchived).toList();

    // En son sohbet en üstte olacak şekilde sırala
    activeChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    // Arama filtresini uygula
    if (_searchQuery.isEmpty) {
      _filteredChats = activeChats;
    } else {
      _filteredChats = activeChats
          .where(
            (chat) =>
                chat.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                chat.lastMessage.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return Container(
      color: AppTheme.surfaceLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGradientStart,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderLight.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // Üstten boşluk
                  // Yeni sohbet butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _createNewChat(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Yeni Sohbet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

            // Arama bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: AppTheme.borderLight.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _updateFilteredChats();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Sohbet ara...',
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Sohbet listesi
            Expanded(
              child: activeChats.isEmpty
                  ? _buildEmptyState()
                  : _filteredChats.isEmpty
                  ? _buildNoSearchResults()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = _filteredChats[index];
                        final isSelected = widget.selectedChat?.id == chat.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentBlue.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium,
                            ),
                            border: isSelected
                                ? Border.all(
                                    color: AppTheme.accentBlue.withOpacity(0.3),
                                  )
                                : Border.all(
                                    color: AppTheme.borderLight.withOpacity(
                                      0.1,
                                    ),
                                  ),
                          ),
                          child: ChatListItem(
                            chat: chat,
                            onTap: () {
                              widget.onChatSelected(chat);
                              // Mobilde drawer'ı kapat
                              widget.onCloseDrawer?.call();
                            },
                            onLongPress: () => _showChatOptions(context, chat),
                          ),
                        );
                      },
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.borderLight.withOpacity(0.2)),
                ),
              ),
              child: Column(
                children: [
                  // Excel Yükle butonu
                  ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                      ),
                      child: Icon(
                        Icons.table_chart,
                        size: 18,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                    title: const Text(
                      'Mesai Yükle',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Çalışan mesai verilerini yükle',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/excel-upload');
                    },
                  ),

                  // // Mesai İstatistikleri butonu
                  // ListTile(
                  //   leading: Container(
                  //     width: 32,
                  //     height: 32,
                  //     decoration: BoxDecoration(
                  //       color: AppTheme.accentPurple.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(
                  //         AppTheme.borderRadiusSmall,
                  //       ),
                  //     ),
                  //     child: Icon(
                  //       Icons.analytics,
                  //       size: 18,
                  //       color: AppTheme.accentPurple,
                  //     ),
                  //   ),
                  //   title: const Text(
                  //     'Mesai İstatistikleri',
                  //     style: TextStyle(color: Colors.white, fontSize: 14),
                  //   ),
                  //   subtitle: const Text(
                  //     'Detaylı mesai analizi',
                  //     style: TextStyle(color: Colors.white70, fontSize: 12),
                  //   ),
                  //   onTap: () {
                  //     Navigator.pushNamed(context, '/mesai-stats');
                  //   },
                  // ),

                  // Arşiv linki
                  if (chats.where((chat) => chat.isArchived).isNotEmpty)
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                        ),
                        child: Icon(
                          Icons.archive,
                          size: 18,
                          color: AppTheme.accentBlue,
                        ),
                      ),
                      title: Text(
                        'Arşiv (${chats.where((chat) => chat.isArchived).length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(context, '/archive'),
                    ),

                  // Ayarlar
                  ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                      ),
                      child: Icon(
                        Icons.settings,
                        size: 18,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                    title: const Text(
                      'Ayarlar',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz sohbet yok',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yeni bir sohbet başlatın',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '"$_searchQuery" için sonuç bulunamadı',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context, Chat chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: chat.title,
        children: [
          CustomBottomSheetItem(
            title: 'Sohbeti Sil',
            subtitle: 'Bu sohbeti kalıcı olarak sil',
            icon: Icons.delete,
            iconColor: AppTheme.accentRed,
            isDestructive: true,
            onTap: () {
              ref.read(chatsProvider.notifier).deleteChat(chat.id);
              Navigator.pop(context);
            },
          ),
          CustomBottomSheetItem(
            title: 'Arşivle',
            subtitle: 'Sohbeti arşivle',
            icon: Icons.archive,
            iconColor: AppTheme.accentBlue,
            onTap: () {
              ref.read(chatsProvider.notifier).archiveChat(chat.id);
              Navigator.pop(context);
            },
          ),
          CustomBottomSheetItem(
            title: 'Sohbeti Düzenle',
            subtitle: 'Sohbet adını değiştir',
            icon: Icons.edit,
            iconColor: AppTheme.accentGreen,
            onTap: () {
              Navigator.pop(context);
              _showEditChatDialog(context, chat);
            },
          ),
        ],
      ),
    );
  }

  void _createNewChat() async {
    final newChat = await ref
        .read(chatsProvider.notifier)
        .createNewChatAndCloseDriver();
    widget.onChatSelected(newChat);
    // Mobilde drawer'ı kapat
    widget.onCloseDrawer?.call();
  }

  void _showEditChatDialog(BuildContext context, Chat chat) {
    CustomDialogHelper.showInputDialog(
      context: context,
      title: 'Sohbeti Düzenle',
      label: 'Sohbet Adı',
      hint: 'Yeni sohbet adını girin',
      initialValue: chat.title,
      confirmText: 'Kaydet',
      cancelText: 'İptal',
      onConfirm: (value) {
        final updatedChat = chat.copyWith(title: value);
        ref.read(chatsProvider.notifier).updateChat(updatedChat);
      },
    );
  }
}
