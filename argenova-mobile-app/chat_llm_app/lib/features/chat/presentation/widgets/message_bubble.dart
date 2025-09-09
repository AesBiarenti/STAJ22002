import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTime;
  final bool isHighlighted;
  final ChatMessage? isCurrentSearchResult;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showTime,
    this.isHighlighted = false,
    this.isCurrentSearchResult,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentResult = isCurrentSearchResult == message;

    return Align(
      alignment: message.isFromUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isFromUser ? 80 : 16,
          right: message.isFromUser ? 16 : 80,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: message.isFromUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isFromUser ? AppTheme.primaryGradient : null,
                color: message.isFromUser
                    ? null
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge)
                    .copyWith(
                      bottomLeft: message.isFromUser
                          ? Radius.circular(AppTheme.borderRadiusLarge)
                          : Radius.circular(AppTheme.borderRadiusSmall),
                      bottomRight: message.isFromUser
                          ? Radius.circular(AppTheme.borderRadiusSmall)
                          : Radius.circular(AppTheme.borderRadiusLarge),
                    ),
                border: message.isFromUser
                    ? null
                    : Border.all(
                        color: isHighlighted || isCurrentResult
                            ? AppTheme.accentBlue
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.3),
                        width: isHighlighted || isCurrentResult ? 2 : 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  if (isCurrentResult)
                    BoxShadow(
                      color: AppTheme.accentBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isFromUser && message.senderName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGradientStart,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.4,
                      backgroundColor: isHighlighted
                          ? AppTheme.accentBlue.withOpacity(0.2)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (showTime)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.isFromUser) ...[
                      _buildStatusIcon(context),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!message.isFromUser) ...[
                      const SizedBox(width: 6),
                      _buildStatusIcon(context),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = AppTheme.accentOrange;
        break;
      case MessageStatus.sent:
        icon = Icons.done;
        color = AppTheme.accentBlue;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = AppTheme.accentBlue;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppTheme.accentGreen;
        break;
      case MessageStatus.failed:
        icon = Icons.error;
        color = AppTheme.accentRed;
        break;
      case MessageStatus.error:
        icon = Icons.error_outline;
        color = AppTheme.accentRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
