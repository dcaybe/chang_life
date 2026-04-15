import 'package:change_life/features/goal/models/goal.dart';
import 'package:change_life/features/goal/provider/goal_providers.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/router/app_router.dart';
import 'package:change_life/services/hive_service.dart';
import 'package:change_life/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(GoalAdapter());

  final storageService = StorageService();
  final hiveService = HiveService();
  await hiveService.init();
  await storageService.init();
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
