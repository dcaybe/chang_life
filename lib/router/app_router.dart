import 'package:change_life/features/goal/models/goal_model.dart';
import 'package:change_life/features/goal/views/goal_detail_screen.dart';
import 'package:change_life/features/goal/views/goal_screen.dart';
import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:change_life/features/habit/views/habit_detail_screen.dart';
import 'package:change_life/features/habit/views/habit_screen.dart';
import 'package:change_life/features/nutrition/models/food_model.dart';
import 'package:change_life/features/nutrition/views/nutrition_detail_screen.dart';
import 'package:change_life/features/workout/views/workout_screen.dart';
import 'package:change_life/views/main_screen.dart';
import 'package:change_life/features/nutrition/views/nutrition_screen.dart';
import 'package:change_life/features/auth/views/login_screen.dart';
import 'package:change_life/services/setting_hive.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static late final GoRouter router;

  static void init(StorageService storageService) {
    final token = storageService.getToken();

    router = GoRouter(
      initialLocation: token != null ? '/habit' : '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/habit',
                  builder: (context, state) =>
                      const HomeScreen(userName: 'Hung'),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) {
                        final habit = state.extra as Habit;
                        return HabitDetailScreen(habit: habit);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/nutrition',
                  builder: (context, state) => const NutritionScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) {
                        final food = state.extra as Food;
                        return NutritionDetailScreen(food: food);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/goal',
                  builder: (context, state) => const GoalScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) {
                        final goal = state.extra as Goal;
                        return GoalDetailScreen(goal: goal);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/workout',
                  builder: (context, state) => const WorkoutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
