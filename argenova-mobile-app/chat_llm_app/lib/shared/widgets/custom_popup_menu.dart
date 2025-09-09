import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CustomPopupMenuItem {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isDestructive;

  const CustomPopupMenuItem({
    required this.title,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.isDestructive = false,
  });
}

class CustomPopupMenu extends StatefulWidget {
  final Widget child;
  final List<CustomPopupMenuItem> items;
  final double width;
  final EdgeInsets padding;

  const CustomPopupMenu({
    super.key,
    required this.child,
    required this.items,
    this.width = 200,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<CustomPopupMenu> createState() => _CustomPopupMenuState();
}

class _CustomPopupMenuState extends State<CustomPopupMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hidePopupMenu();
    super.dispose();
  }

  void _showPopupMenu() {
    if (_isOpen) {
      _hidePopupMenu();
      return;
    }

    setState(() => _isOpen = true);
    _animationController.forward();

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonSize = button.size;
    final screenSize = MediaQuery.of(context).size;

    // Popup'ın konumunu hesapla
    double left = buttonPosition.dx + buttonSize.width - widget.width;
    double top = buttonPosition.dy + buttonSize.height + 8;

    // Ekranın sağına taşmasını engelle
    if (left + widget.width > screenSize.width) {
      left = screenSize.width - widget.width - 16;
    }

    // Ekranın soluna taşmasını engelle
    if (left < 16) {
      left = 16;
    }

    // Ekranın altına taşmasını engelle
    final popupHeight = (widget.items.length * 60) + 80; // Yaklaşık yükseklik
    if (top + popupHeight > screenSize.height) {
      top = buttonPosition.dy - popupHeight - 8;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Tam ekran arka plan overlay - tıklanabilir alan
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hidePopupMenu,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Popup içeriği
              Positioned(
                left: left,
                top: top,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: GestureDetector(
                            onTap: () {
                              // Popup içine tıklandığında kapanmasın
                            },
                            child: Container(
                              width: widget.width,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusLarge,
                                ),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Handle bar
                                  Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  // Menu items
                                  ...widget.items.map(
                                    (item) => _buildMenuItem(context, item),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePopupMenu() {
    if (!_isOpen || _overlayEntry == null) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) {
        setState(() => _isOpen = false);
      }
    });
  }

  Widget _buildMenuItem(BuildContext context, CustomPopupMenuItem item) {
    final iconColor =
        item.iconColor ??
        (item.isDestructive
            ? AppTheme.accentRed
            : AppTheme.primaryGradientStart);
    final backgroundColor = item.isDestructive
        ? AppTheme.accentRed.withOpacity(0.1)
        : iconColor.withOpacity(0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _hidePopupMenu();
          Future.delayed(const Duration(milliseconds: 100), () {
            item.onTap?.call();
          });
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(item.icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: item.isDestructive
                        ? AppTheme.accentRed
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _showPopupMenu, child: widget.child);
  }
}
