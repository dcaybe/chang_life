import 'package:change_life/features/goal/models/goal.dart';
import 'package:change_life/features/habit/models/habit.dart';
import 'package:change_life/features/goal/provider/goal_providers.dart';
import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:change_life/features/nutrition/providers/nutrition_provider.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/router/app_router.dart';
import 'package:change_life/services/goal_hive_service.dart';
import 'package:change_life/services/habit_hive_service.dart';
import 'package:change_life/services/setting_hive.dart';
import 'package:change_life/features/nutrition/models/food.dart';
import 'package:change_life/services/food_hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(FoodAdapter());

  final storageService = StorageService();
  final goalHiveService = GoalHiveService();
  final habitHiveService = HabitHiveService();
  final foodHiveService = FoodHiveService();
  await goalHiveService.init();
  await habitHiveService.init();
  await foodHiveService.init();
  await storageService.init();

  // Khởi tạo Router sau khi có storageService
  AppRouter.init(storageService);
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        goalHiveServiceProvider.overrideWithValue(goalHiveService),
        habitHiveServiceProvider.overrideWithValue(habitHiveService),
        foodHiveServiceProvider.overrideWithValue(foodHiveService),
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
