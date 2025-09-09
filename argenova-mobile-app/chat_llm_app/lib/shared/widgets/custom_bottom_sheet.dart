import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double? maxHeight;
  final bool showHandle;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.children,
    this.maxHeight,
    this.showHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (title.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomSheetItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isDestructive;
  final String? subtitle;

  const CustomBottomSheetItem({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.isDestructive = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        this.iconColor ??
        (isDestructive ? AppTheme.accentRed : AppTheme.primaryGradientStart);
    final backgroundColor = isDestructive
        ? AppTheme.accentRed.withOpacity(0.1)
        : iconColor.withOpacity(0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? AppTheme.accentRed
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
