import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/chat.dart';
import '../../../../shared/providers/chat_provider.dart';
import '../../../../shared/widgets/animated_card.dart';
import '../../../../shared/widgets/animated_search_bar.dart';
import '../../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/widgets/custom_popup_menu.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../widgets/chat_list_item.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  String _searchQuery = '';
  List<Chat> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _filteredChats = ref.read(chatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatsProvider);

    // Arama filtresini uygula ve arşivlenmiş sohbetleri hariç tut
    if (_searchQuery.isEmpty) {
      _filteredChats = chats.where((chat) => !chat.isArchived).toList();
    } else {
      _filteredChats = chats
          .where(
            (chat) =>
                !chat.isArchived &&
                (chat.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    chat.lastMessage.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    )),
          )
          .toList();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Sohbetler',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI ile sohbet edin',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    AnimatedSearchBar(
                      hintText: 'Sohbet ara...',
                      onSearch: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    CustomPopupMenu(
                      items: [
                        CustomPopupMenuItem(
                          title: 'Yeni Grup',
                          icon: Icons.group_add,
                          iconColor: AppTheme.accentBlue,
                          onTap: () {
                            _showNewGroupDialog(context, ref);
                          },
                        ),

                        CustomPopupMenuItem(
                          title:
                              'Arşiv (${chats.where((chat) => chat.isArchived).length})',
                          icon: Icons.archive,
                          iconColor: AppTheme.accentPurple,
                          onTap: () {
                            Navigator.pushNamed(context, '/archive');
                          },
                        ),
                        CustomPopupMenuItem(
                          title: 'Ayarlar',
                          icon: Icons.settings,
                          iconColor: AppTheme.accentOrange,
                          onTap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ],
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: chats.isEmpty
                  ? _buildEmptyState(context)
                  : _searchQuery.isNotEmpty && _filteredChats.isEmpty
                  ? _buildNoSearchResults(context)
                  : _buildQuickActions(context, ref),
            ),
          ),
          if (_filteredChats.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final chat = _filteredChats[index];
                  return AnimatedCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    onTap: () => _navigateToChat(context, chat),
                    child: ChatListItem(
                      chat: chat,
                      onTap: () => _navigateToChat(context, chat),
                      onLongPress: () => _showChatOptions(context, ref, chat),
                    ),
                  );
                }, childCount: _filteredChats.length),
              ),
            ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.secondaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusExtraLarge),
          boxShadow: AppTheme.mediumShadow,
        ),
        child: FloatingActionButton(
          onPressed: () => _showNewChatDialog(context, ref),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AnimatedCard(
      child: Column(
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
          Text(
            'Henüz sohbet yok',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir sohbet başlatmak için aşağıdaki butona tıklayın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'İlk Sohbeti Başlat',
            icon: Icons.chat,
            onPressed: () => _showNewChatDialog(context, ref),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults(BuildContext context) {
    return AnimatedCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Icon(Icons.search_off, size: 40, color: AppTheme.accentBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç bulunamadı',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_searchQuery" için sonuç bulunamadı',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Eylemler',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnimatedCard(
                onTap: () => _showNewChatDialog(context, ref),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                      ),
                      child: const Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni Sohbet',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Son Sohbetler',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _navigateToChat(BuildContext context, Chat chat) {
    Navigator.pushNamed(context, '/chat', arguments: chat);
  }

  void _showChatOptions(BuildContext context, WidgetRef ref, Chat chat) {
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
            title: chat.isArchived ? 'Arşivden Çıkar' : 'Arşivle',
            subtitle: chat.isArchived
                ? 'Sohbeti arşivden çıkar'
                : 'Sohbeti arşivle',
            icon: chat.isArchived ? Icons.unarchive : Icons.archive,
            iconColor: AppTheme.accentBlue,
            onTap: () {
              if (chat.isArchived) {
                ref.read(chatsProvider.notifier).unarchiveChat(chat.id);
              } else {
                ref.read(chatsProvider.notifier).archiveChat(chat.id);
              }
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
              _showEditChatDialog(context, ref, chat);
            },
          ),
        ],
      ),
    );
  }

  void _showEditChatDialog(BuildContext context, WidgetRef ref, Chat chat) {
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

  void _showNewGroupDialog(BuildContext context, WidgetRef ref) {
    CustomDialogHelper.showInputDialog(
      context: context,
      title: 'Yeni Grup',
      label: 'Grup Adı',
      hint: 'Örn: Aile Grubu',
      confirmText: 'Oluştur',
      cancelText: 'İptal',
      onConfirm: (value) {
        final newGroup = Chat(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: value,
          messages: [],
          createdAt: DateTime.now(),
          lastMessageTime: DateTime.now(),
          isGroupChat: true,
        );
        ref.read(chatsProvider.notifier).addChat(newGroup);
        // Dialog'un kapanmasını bekle, sonra navigasyon yap
        Future.delayed(const Duration(milliseconds: 100), () {
          _navigateToChat(context, newGroup);
        });
      },
    );
  }

  void _showNewChatDialog(BuildContext context, WidgetRef? ref) {
    CustomDialogHelper.showInputDialog(
      context: context,
      title: 'Yeni Sohbet',
      label: 'Sohbet Adı',
      hint: 'Örn: AI Asistan',
      confirmText: 'Oluştur',
      cancelText: 'İptal',
      onConfirm: (value) {
        if (ref != null) {
          final newChat = Chat(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: value,
            messages: [],
            createdAt: DateTime.now(),
            lastMessageTime: DateTime.now(),
          );
          ref.read(chatsProvider.notifier).addChat(newChat);
          // Dialog'un kapanmasını bekle, sonra navigasyon yap
          Future.delayed(const Duration(milliseconds: 100), () {
            _navigateToChat(context, newChat);
          });
        }
      },
    );
  }

  // Yeni sohbet oluştur ve driver'ı kapat
  void _createNewChatAndNavigate(BuildContext context, WidgetRef ref) async {
    try {
      // Yeni sohbet oluştur ve driver'ı kapat
      final newChat = await ref
          .read(chatsProvider.notifier)
          .createNewChatAndCloseDriver();

      // Sohbete git
      _navigateToChat(context, newChat);
    } catch (e) {
      // Hata durumunda normal sohbet oluştur
      _showNewChatDialog(context, ref);
    }
  }
}
