import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('flashcards');

  // Initialize SQLite only on mobile (not web)
  if (!kIsWeb) {
    await DBService.instance.database;
  }

  runApp(
    const ProviderScope(
      child: StudyAIApp(),
    ),
  );
}

class StudyAIApp extends ConsumerWidget {
  const StudyAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'StudyAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final box = Hive.box('settings');
  final isDark = box.get('isDark', defaultValue: false);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});