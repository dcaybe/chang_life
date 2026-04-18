import 'package:change_life/features/goal/models/goal_model.dart';
import 'package:change_life/features/goal/providers/goal_provider.dart';
import 'package:change_life/services/goal_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalViewModel extends Notifier<List<Goal>> {
  late final GoalHiveService service;
  @override
  List<Goal> build() {
    service = ref.read(goalHiveServiceProvider);
    return service.getGoals();
  }

  void addGoal(Goal goal) {
    service.addGoal(goal);
    state = service.getGoals();
  }

  void removeGoal(int index) {
    service.removeGoal(index);
    state = service.getGoals();
  }
}
