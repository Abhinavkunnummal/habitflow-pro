import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api/api_providers.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline persistent storage & session storage
  final localStorage = await LocalStorage.create();
  final sessionStorage = await SessionStorage.create();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
        sessionStorageProvider.overrideWithValue(sessionStorage),
      ],
      child: const HabitFlowProApp(),
    ),
  );
}

class HabitFlowProApp extends ConsumerWidget {
  const HabitFlowProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'HabitFlow Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
