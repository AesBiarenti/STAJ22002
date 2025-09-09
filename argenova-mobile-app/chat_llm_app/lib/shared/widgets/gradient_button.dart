import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final LinearGradient? gradient;
  final IconData? icon;
  final bool isOutlined;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.gradient,
    this.icon,
    this.isOutlined = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppTheme.primaryGradient;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (widget.onPressed != null && !widget.isLoading) {
                setState(() => _isPressed = true);
                _animationController.forward();
              }
            },
            onTapUp: (_) {
              if (widget.onPressed != null && !widget.isLoading) {
                setState(() => _isPressed = false);
                _animationController.reverse();
              }
            },
            onTapCancel: () {
              if (widget.onPressed != null && !widget.isLoading) {
                setState(() => _isPressed = false);
                _animationController.reverse();
              }
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isOutlined ? null : gradient,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: widget.isOutlined
                    ? Border.all(color: AppTheme.primaryGradientStart, width: 2)
                    : null,
                boxShadow: widget.isOutlined
                    ? null
                    : [
                        BoxShadow(
                          color: AppTheme.primaryGradientStart.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusLarge,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isOutlined
                                      ? AppTheme.primaryGradientStart
                                      : Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: widget.isOutlined
                                        ? AppTheme.primaryGradientStart
                                        : Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.text,
                                  style: TextStyle(
                                    color: widget.isOutlined
                                        ? AppTheme.primaryGradientStart
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
