import 'package:change_life/features/goal/models/goal_model.dart';
import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:change_life/features/goal/providers/goal_provider.dart';
import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/router/app_router.dart';
import 'package:change_life/services/goal_hive_service.dart';
import 'package:change_life/services/habit_hive_service.dart';
import 'package:change_life/services/setting_hive.dart';
import 'package:change_life/features/nutrition/models/food_model.dart';
import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/services/food_hive_service.dart';
import 'package:change_life/services/nutrition_hive_service.dart';
import 'package:change_life/features/nutrition/providers/nutrition_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:change_life/features/workout/models/workout_model.dart';
import 'package:change_life/features/workout/models/exercise_model.dart';
import 'package:change_life/services/workout_hive_service.dart';
import 'package:change_life/features/workout/providers/workout_provider.dart';
import 'package:change_life/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(SubGoalAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(MealPlanAdapter());
  Hive.registerAdapter(WorkoutSessionAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutSetAdapter());
  Hive.registerAdapter(ExerciseLogAdapter());

  final storageService = StorageService();
  final goalHiveService = GoalHiveService();
  final habitHiveService = HabitHiveService();
  final foodHiveService = FoodHiveService();
  final nutritionHiveService = NutritionHiveService();
  final workoutHiveService = WorkoutHiveService();
  await goalHiveService.init();
  await habitHiveService.init();
  await foodHiveService.init();
  await nutritionHiveService.init();
  await workoutHiveService.init();
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
        nutritionHiveServiceProvider.overrideWithValue(nutritionHiveService),
        workoutHiveServiceProvider.overrideWithValue(workoutHiveService),
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
      theme: settings.currentTheme == AppThemeMode.sereneBlue
          ? AppTheme.sereneBlueTheme
          : AppTheme.kineticDisciplineTheme,
    );
  }
}
