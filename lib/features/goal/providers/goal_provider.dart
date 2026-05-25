import 'package:change_life/features/goal/models/goal_model.dart';
import 'package:change_life/features/goal/viewmodels/goal_viewmodel.dart';
import 'package:change_life/services/goal_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goalHiveServiceProvider = Provider<GoalHiveService>((ref) {
  throw UnimplementedError();
});

final goalVMProvider = NotifierProvider<GoalViewModel, List<Goal>>(GoalViewModel.new);

final inProgressGoalsProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(goalVMProvider);
  return goals.where((g) => g.progress < 1).toList();
});

final completedGoalsProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(goalVMProvider);
  return goals.where((g) => g.progress == 1 && g.subGoals.isNotEmpty).toList();
});
