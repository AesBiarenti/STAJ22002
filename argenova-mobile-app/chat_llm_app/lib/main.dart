import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/chat/presentation/pages/archive_page.dart';
import 'features/chat/presentation/pages/chat_home_page.dart';
import 'features/excel/presentation/pages/excel_upload_page.dart';
import 'features/excel/presentation/pages/mesai_stats_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'shared/models/chat.dart';
import 'shared/models/chat_message.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat
  await Hive.initFlutter();

  // Hive adaptörlerini kaydet
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(MessageStatusAdapter());
  Hive.registerAdapter(ChatAdapter());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'AI Chat App',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const ChatHomePage(),
        '/settings': (context) => const SettingsPage(),
        '/archive': (context) => const ArchivePage(),
        '/excel-upload': (context) => const ExcelUploadPage(),
        '/mesai-stats': (context) => const MesaiStatsPage(),
      },
    );
  }
}
