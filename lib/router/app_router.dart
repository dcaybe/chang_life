import 'package:flutter/material.dart';
import 'package:change_life/features/goal/models/goal_model.dart';
import 'package:change_life/features/goal/views/goal_detail_screen.dart';
import 'package:change_life/features/goal/views/goal_screen.dart';
import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:change_life/features/habit/views/habit_detail_screen.dart';
import 'package:change_life/features/habit/views/habit_screen.dart';
import 'package:change_life/features/habit/views/habit_statistics_screen.dart';
import 'package:change_life/features/nutrition/models/food_model.dart';
import 'package:change_life/features/nutrition/views/nutrition_detail_screen.dart';
import 'package:change_life/features/onboarding/views/onboarding_screen.dart';
import 'package:change_life/features/onboarding/views/splash_screen.dart';
import 'package:change_life/features/workout/models/workout_model.dart';
import 'package:change_life/features/workout/views/active_workout_screen.dart';
import 'package:change_life/features/workout/views/workout_detail_screen.dart';
import 'package:change_life/features/workout/views/workout_screen.dart';
import 'package:change_life/views/main_screen.dart';
import 'package:change_life/features/nutrition/views/nutrition_screen.dart';
import 'package:change_life/features/nutrition/views/nutrition_design_screen.dart';
import 'package:change_life/features/auth/views/login_screen.dart';
import 'package:change_life/features/profile/views/profile_screen.dart';
import 'package:change_life/features/profile/views/settings_screen.dart';
import 'package:change_life/services/setting_hive.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static late final GoRouter router;
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static void init(StorageService storageService) {
    // Splash always shows first for 2s, then navigates
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
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
                  builder: (context, state) => const HomeScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) {
                        final habit = state.extra as Habit;
                        return HabitDetailScreen(habit: habit);
                      },
                    ),
                    GoRoute(
                      path: 'statistics',
                      builder: (context, state) => const HabitStatisticsScreen(),
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
                    GoRoute(
                      path: 'design',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const NutritionDesignScreen(),
                    ),
                  ],
                ),
              ],
            ),
            /*
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
            */
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/workout',
                  builder: (context, state) => const WorkoutScreen(),
                  routes: [
                    GoRoute(
                      path: 'active',
                      builder: (context, state) => const ActiveWorkoutScreen(),
                    ),
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) {
                        final session = state.extra as WorkoutSession;
                        return WorkoutDetailScreen(session: session);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                  routes: [
                    GoRoute(
                      path: 'settings',
                      builder: (context, state) => const SettingsScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
