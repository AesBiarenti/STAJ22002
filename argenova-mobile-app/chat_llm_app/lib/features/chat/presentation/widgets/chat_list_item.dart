import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/chat.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAvatar(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.title.isNotEmpty ? chat.title : 'Yeni Sohbet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: chat.unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusSmall,
                            ),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: chat.unreadCount > 0
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: chat.unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: chat.avatarUrl != null ? null : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: chat.avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              child: Image.network(
                chat.avatarUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(context),
              ),
            )
          : _buildAvatarFallback(context),
    );
  }

  Widget _buildAvatarFallback(BuildContext context) {
    return Center(
      child: Text(
        chat.title.isNotEmpty ? chat.title[0].toUpperCase() : 'N',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}g';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}s';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}d';
    } else {
      return 'şimdi';
    }
  }
}
