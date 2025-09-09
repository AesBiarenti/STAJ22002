import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool useDarkGradient;
  final EdgeInsetsGeometry? padding;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.useDarkGradient = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: useDarkGradient
            ? AppTheme.backgroundGradientDark
            : AppTheme.backgroundGradientLight,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}

class GradientContainer extends StatelessWidget {
  final Widget child;
  final bool useDarkGradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const GradientContainer({
    super.key,
    required this.child,
    this.useDarkGradient = false,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: useDarkGradient
            ? AppTheme.surfaceGradientDark
            : AppTheme.surfaceGradientLight,
        borderRadius: borderRadius,
        border: border,
      ),
      child: child,
    );
  }
}
