import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/animated_card.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return GradientScaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Ayarlar',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uygulama tercihleri',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Görünüm Bölümü
                _buildSectionTitle(context, 'Görünüm'),
                AnimatedCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildSettingsItem(
                    context: context,
                    icon: Icons.palette,
                    title: 'Tema',
                    subtitle: _getThemeText(currentTheme),
                    onTap: () => _showThemeDialog(context, ref),
                  ),
                ),

                // // Sohbet Bölümü
                // _buildSectionTitle(context, 'Sohbet'),
                // AnimatedCard(
                //   margin: const EdgeInsets.only(bottom: 16),
                //   child: Column(
                //     children: [
                //       _buildSettingsItem(
                //         context: context,
                //         icon: Icons.auto_awesome,
                //         title: 'AI Model Ayarları',
                //         subtitle: 'LLM model konfigürasyonu',
                //         onTap: () {
                //           // TODO: AI model ayarları
                //         },
                //       ),
                //     ],
                //   ),
                // ),

                // Uygulama Bölümü
                _buildSectionTitle(context, 'Uygulama'),
                AnimatedCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        context: context,
                        icon: Icons.info,
                        title: 'Hakkında',
                        subtitle: 'Versiyon 1.0.0',
                        onTap: () {
                          // TODO: Hakkında sayfası
                        },
                      ),
                      // _buildDivider(),
                      // _buildSettingsItem(
                      //   context: context,
                      //   icon: Icons.bug_report,
                      //   title: 'Hata Bildir',
                      //   subtitle: 'Sorunları bildir',
                      //   onTap: () {
                      //     // TODO: Hata bildirme
                      //   },
                      // ),
                      // _buildDivider(),
                      // _buildSettingsItem(
                      //   context: context,
                      //   icon: Icons.feedback,
                      //   title: 'Geri Bildirim',
                      //   subtitle: 'Görüşlerinizi paylaşın',
                      //   onTap: () {
                      //     // TODO: Geri bildirim
                      //   },
                      // ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
                child: Icon(icon, color: AppTheme.accentBlue, size: 20),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey.withOpacity(0.2),
    );
  }

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Açık';
      case ThemeMode.dark:
        return 'Koyu';
      case ThemeMode.system:
        return 'Sistem';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final options = [
      const CustomSelectionOption<ThemeMode>(
        title: 'Açık',
        value: ThemeMode.light,
        icon: Icons.light_mode,
      ),
      const CustomSelectionOption<ThemeMode>(
        title: 'Koyu',
        value: ThemeMode.dark,
        icon: Icons.dark_mode,
      ),
      const CustomSelectionOption<ThemeMode>(
        title: 'Sistem',
        value: ThemeMode.system,
        icon: Icons.settings_system_daydream,
      ),
    ];

    CustomDialogHelper.showSelectionDialog<ThemeMode>(
      context: context,
      title: 'Tema Seçin',
      options: options,
      selectedValue: ref.watch(themeProvider),
      onSelect: (value) {
        ref.read(themeProvider.notifier).setTheme(value);
      },
    );
  }
}
