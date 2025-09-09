import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableHover;
  final bool enableShadow;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.enableHover = true,
    this.enableShadow = true,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableHover && widget.onTap != null) {
      setState(() => _isHovered = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableHover && widget.onTap != null) {
      setState(() => _isHovered = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableHover && widget.onTap != null) {
      setState(() => _isHovered = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              margin: widget.margin ?? const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 1,
                ),
                boxShadow: widget.enableShadow
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.05 + (_elevationAnimation.value * 0.05),
                          ),
                          blurRadius: 10 + (_elevationAnimation.value * 10),
                          offset: Offset(
                            0,
                            4 + (_elevationAnimation.value * 4),
                          ),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
