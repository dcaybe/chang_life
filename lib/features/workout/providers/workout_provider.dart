import 'package:change_life/features/workout/models/workout_model.dart';
import 'package:change_life/features/workout/viewmodels/workout_viewmodel.dart';
import 'package:change_life/features/workout/viewmodels/active_workout_viewmodel.dart';
import 'package:change_life/services/workout_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutHiveServiceProvider = Provider<WorkoutHiveService>((ref) {
  throw UnimplementedError('workoutHiveServiceProvider not initialized');
});

final workoutViewModelProvider = StateNotifierProvider<WorkoutViewModel, List<WorkoutSession>>((ref) {
  final hiveService = ref.watch(workoutHiveServiceProvider);
  return WorkoutViewModel(hiveService);
});

final activeWorkoutViewModelProvider = StateNotifierProvider<ActiveWorkoutViewModel, ActiveWorkoutState>((ref) {
  final hiveService = ref.watch(workoutHiveServiceProvider);
  return ActiveWorkoutViewModel(
    hiveService,
    onWorkoutCompleted: (session) {
      ref.read(workoutViewModelProvider.notifier).addWorkout(session);
    },
    onUpdateTemplate: (template) {
      ref.read(workoutViewModelProvider.notifier).updateWorkout(template);
    },
  );
});


