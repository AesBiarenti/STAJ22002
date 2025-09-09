import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'gradient_button.dart';

/// Özel tasarımlı dialog widget'ı
class CustomDialog extends StatelessWidget {
  /// Dialog başlığı
  final String title;

  /// Dialog içeriği
  final Widget content;

  /// Dialog genişliği
  final double? width;

  /// Dialog yüksekliği
  final double? height;

  /// Dialog oluşturucu
  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width ?? 400,
        height: height,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.strongShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                  topRight: Radius.circular(AppTheme.borderRadiusLarge),
                ),
              ),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Content
            Flexible(
              child: Padding(padding: const EdgeInsets.all(20), child: content),
            ),
          ],
        ),
      ),
    );
  }
}

/// Input dialog widget'ı
class CustomInputDialog extends StatefulWidget {
  /// Dialog başlığı
  final String title;

  /// Input label'ı
  final String label;

  /// Input hint'i
  final String hint;

  /// Başlangıç değeri
  final String? initialValue;

  /// Onay butonu metni
  final String confirmText;

  /// İptal butonu metni
  final String cancelText;

  /// Onay callback'i
  final Function(String)? onConfirm;

  /// İptal callback'i
  final VoidCallback? onCancel;

  /// Input dialog oluşturucu
  const CustomInputDialog({
    super.key,
    required this.title,
    required this.label,
    required this.hint,
    this.initialValue,
    this.confirmText = 'Kaydet',
    this.cancelText = 'İptal',
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<CustomInputDialog> createState() => _CustomInputDialogState();
}

class _CustomInputDialogState extends State<CustomInputDialog> {
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _updateValidation();
    _controller.addListener(_updateValidation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValidation() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input field
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                labelStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              onSubmitted: (_) {
                if (_isValid) {
                  widget.onConfirm?.call(_controller.text.trim());
                  Navigator.pop(context);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget.onCancel?.call();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.cancelText,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  text: widget.confirmText,
                  onPressed: _isValid
                      ? () {
                          widget.onConfirm?.call(_controller.text.trim());
                          Navigator.pop(context);
                        }
                      : null,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Selection dialog widget'ı
class CustomSelectionDialog<T> extends StatelessWidget {
  /// Dialog başlığı
  final String title;

  /// Seçenekler listesi
  final List<CustomSelectionOption<T>> options;

  /// Mevcut seçili değer
  final T? selectedValue;

  /// Seçim callback'i
  final Function(T)? onSelect;

  /// İptal callback'i
  final VoidCallback? onCancel;

  /// Selection dialog oluşturucu
  const CustomSelectionDialog({
    super.key,
    required this.title,
    required this.options,
    this.selectedValue,
    this.onSelect,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Options
          ...options.map((option) => _buildOption(context, option)),
          const SizedBox(height: 16),
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                onCancel?.call();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
              ),
              child: Text(
                'İptal',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, CustomSelectionOption<T> option) {
    final isSelected = option.value == selectedValue;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.accentBlue.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: isSelected
              ? AppTheme.accentBlue
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onSelect?.call(option.value);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentBlue
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentBlue,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Text(
                    option.title,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accentBlue
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                // Icon
                if (option.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    option.icon,
                    color: isSelected
                        ? AppTheme.accentBlue
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seçim seçeneği modeli
class CustomSelectionOption<T> {
  /// Seçenek başlığı
  final String title;

  /// Seçenek değeri
  final T value;

  /// Seçenek ikonu
  final IconData? icon;

  /// Seçim seçeneği oluşturucu
  const CustomSelectionOption({
    required this.title,
    required this.value,
    this.icon,
  });
}

/// Dialog gösterme fonksiyonları
class CustomDialogHelper {
  /// Input dialog göster
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    required String label,
    required String hint,
    String? initialValue,
    String confirmText = 'Kaydet',
    String cancelText = 'İptal',
    Function(String)? onConfirm,
    VoidCallback? onCancel,
  }) async {
    String? result;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomInputDialog(
        title: title,
        label: label,
        hint: hint,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: (value) {
          result = value;
          onConfirm?.call(value);
        },
        onCancel: onCancel,
      ),
    );

    return result;
  }

  /// Selection dialog göster
  static Future<T?> showSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required List<CustomSelectionOption<T>> options,
    T? selectedValue,
    Function(T)? onSelect,
    VoidCallback? onCancel,
  }) async {
    T? result;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomSelectionDialog<T>(
        title: title,
        options: options,
        selectedValue: selectedValue,
        onSelect: (value) {
          result = value;
          onSelect?.call(value);
        },
        onCancel: onCancel,
      ),
    );

    return result;
  }
}
