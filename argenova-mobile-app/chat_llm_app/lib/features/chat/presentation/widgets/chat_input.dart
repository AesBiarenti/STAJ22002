import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInput({super.key, required this.controller, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  bool _hasText = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusExtraLarge,
                  ),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: AppTheme.softShadow,
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    hintText: 'Mesaj yazın...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTapDown: (_) {
                      if (_hasText || !_hasText) {
                        _animationController.forward();
                      }
                    },
                    onTapUp: (_) {
                      _animationController.reverse();
                      if (_hasText) {
                        widget.onSend();
                      } else {
                        // Mesaj yazmaya devam et
                      }
                    },
                    onTapCancel: () {
                      _animationController.reverse();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: _hasText
                            ? AppTheme.primaryGradient
                            : AppTheme.secondaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusExtraLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_hasText
                                        ? AppTheme.primaryGradientStart
                                        : AppTheme.secondaryGradientStart)
                                    .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
