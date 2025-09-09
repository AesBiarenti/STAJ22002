import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/chat.dart';
import '../../../../shared/providers/chat_provider.dart';
import '../../../../shared/widgets/animated_card.dart';
import '../../../../shared/widgets/animated_search_bar.dart';
import '../../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../widgets/chat_list_item.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  String _searchQuery = '';
  List<Chat> _filteredArchivedChats = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredChats();
  }

  void _updateFilteredChats() {
    final chats = ref.read(chatsProvider);
    final archivedChats = chats.where((chat) => chat.isArchived).toList();

    if (_searchQuery.isEmpty) {
      _filteredArchivedChats = archivedChats;
    } else {
      _filteredArchivedChats = archivedChats
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
    final archivedChats = chats.where((chat) => chat.isArchived).toList();

    // Arama filtresini uygula
    if (_searchQuery.isEmpty) {
      _filteredArchivedChats = archivedChats;
    } else {
      _filteredArchivedChats = archivedChats
          .where(
            (chat) =>
                chat.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                chat.lastMessage.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return GradientScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
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
                          'Arşiv',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Arşivlenmiş sohbetler',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white.withOpacity(0.8)),
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
                      hintText: 'Arşivde ara...',
                      onSearch: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: archivedChats.isEmpty
                  ? _buildEmptyArchive(context)
                  : _searchQuery.isNotEmpty && _filteredArchivedChats.isEmpty
                  ? _buildNoSearchResults(context)
                  : _buildArchiveInfo(context, archivedChats.length),
            ),
          ),
          if (_filteredArchivedChats.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final chat = _filteredArchivedChats[index];
                  return AnimatedCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    onTap: () => _navigateToChat(context, chat),
                    child: ChatListItem(
                      chat: chat,
                      onTap: () => _navigateToChat(context, chat),
                      onLongPress: () =>
                          _showArchiveOptions(context, ref, chat),
                    ),
                  );
                }, childCount: _filteredArchivedChats.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyArchive(BuildContext context) {
    return AnimatedCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Icon(Icons.archive, size: 40, color: AppTheme.accentBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Arşiv boş',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Arşivlenmiş sohbet bulunmuyor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
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
              color: AppTheme.accentBlue.withOpacity(0.1),
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveInfo(BuildContext context, int count) {
    return AnimatedCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(Icons.archive, color: AppTheme.accentBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arşivlenmiş Sohbetler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count sohbet arşivlenmiş',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, Chat chat) {
    Navigator.pushNamed(context, '/chat', arguments: chat);
  }

  void _showArchiveOptions(BuildContext context, WidgetRef ref, Chat chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: chat.title,
        children: [
          CustomBottomSheetItem(
            title: 'Arşivden Çıkar',
            subtitle: 'Sohbeti arşivden çıkar',
            icon: Icons.unarchive,
            iconColor: AppTheme.accentBlue,
            onTap: () {
              ref.read(chatsProvider.notifier).unarchiveChat(chat.id);
              Navigator.pop(context);
            },
          ),
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
        ],
      ),
    );
  }
}
