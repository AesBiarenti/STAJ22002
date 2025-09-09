import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class ChatLayout extends StatefulWidget {
  final Widget sidebar;
  final Widget mainContent;
  final bool showSidebar;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onCloseSidebar;

  const ChatLayout({
    super.key,
    required this.sidebar,
    required this.mainContent,
    this.showSidebar = true,
    this.onToggleSidebar,
    this.onCloseSidebar,
  });

  @override
  State<ChatLayout> createState() => ChatLayoutState();
}

class ChatLayoutState extends State<ChatLayout> {
  bool _isSidebarOpen = false;
  double _dragOffset = 0.0;
  double _startDragX = 0.0;

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
      _dragOffset = 0.0;
    });
    widget.onCloseSidebar?.call();
  }

  // Bu metod ChatSidebar'dan çağrılacak
  void closeDrawer() {
    _closeSidebar();
  }

  // GlobalKey ile erişim için static metod
  static void closeDrawerFromKey(GlobalKey<ChatLayoutState> key) {
    key.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return GradientScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Ana içerik
            Row(
              children: [
                // Sidebar - Tablet'te her zaman görünür
                if (isTablet)
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      border: Border(
                        right: BorderSide(
                          color: AppTheme.borderLight.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: widget.sidebar,
                  ),

                // Ana içerik alanı
                Expanded(child: widget.mainContent),
              ],
            ),

            // Mobilde sidebar toggle butonu
            if (!isTablet)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isSidebarOpen = !_isSidebarOpen;
                        _dragOffset = 0.0;
                      });
                      widget.onToggleSidebar?.call();
                    },
                    icon: Icon(
                      _isSidebarOpen ? Icons.close : Icons.menu,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
              ),

            // Mobilde drawer overlay - Tıklanabilir arka plan
            if (!isTablet && _isSidebarOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeSidebar,
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),

            // Mobilde sidebar drawer - Sürüklenebilir
            if (!isTablet)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? _dragOffset : -320 + _dragOffset,
                top: 0,
                bottom: 0,
                width: 320,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    _startDragX = details.globalPosition.dx;
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isSidebarOpen) {
                      final currentX = details.globalPosition.dx;
                      final deltaX = currentX - _startDragX;

                      setState(() {
                        // Sadece sola sürüklemeye izin ver (negatif değerler)
                        _dragOffset = deltaX < 0 ? deltaX : 0;
                      });
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isSidebarOpen) {
                      final velocity = details.velocity.pixelsPerSecond.dx;
                      final dragDistance = _dragOffset.abs();

                      // Hızlı sola sürükleme veya yeterli mesafe
                      if (velocity < -300 || dragDistance > 80) {
                        _closeSidebar();
                      } else {
                        // Geri döndür
                        setState(() {
                          _dragOffset = 0.0;
                        });
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      border: Border(
                        right: BorderSide(
                          color: AppTheme.borderLight.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: widget.sidebar,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatDrawer extends StatelessWidget {
  final Widget child;
  final bool isOpen;
  final VoidCallback? onClose;

  const ChatDrawer({
    super.key,
    required this.child,
    required this.isOpen,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isOpen ? 320 : 0,
      child: Stack(
        children: [
          // Drawer içeriği
          Container(
            width: 320,
            decoration: BoxDecoration(
              gradient: AppTheme.surfaceGradientLight,
              border: Border(
                right: BorderSide(
                  color: AppTheme.borderLight.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: child,
          ),

          // Kapatma butonu
          if (isOpen)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: onClose,
                backgroundColor: AppTheme.accentRed,
                foregroundColor: Colors.white,
                child: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    );
  }
}
