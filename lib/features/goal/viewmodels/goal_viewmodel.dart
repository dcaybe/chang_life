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

  /// MVVM: ViewModel tạo Model, View chỉ truyền raw data
  void createGoal({
    required String title,
    required String description,
    required DateTime deadline,
  }) {
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      deadline: deadline,
      subGoals: [],
    );
    addGoal(goal);
  }

  /// MVVM: ViewModel xử lý thêm SubGoal, View chỉ truyền title
  void addSubGoal(Goal goal, String title) {
    final newSubGoal = SubGoal(
      id: DateTime.now().toString(),
      title: title,
    );
    final updatedGoal = goal.copyWith(
      subGoals: [...goal.subGoals, newSubGoal],
    );
    updateGoal(goal.key, updatedGoal);
  }

  void removeGoal(int index) {
    service.removeGoal(index);
    state = service.getGoals();
  }

  void updateGoal(dynamic originalKey, Goal updatedGoal) {
    if (originalKey == null) return;
    final box = service.getBox();
    box.put(originalKey, updatedGoal);
    state = service.getGoals();
  }

  void toggleSubGoal(Goal goal, String subGoalId) {
    final subGoals = goal.subGoals.map((sg) {
      if (sg.id == subGoalId) {
        return sg.copyWith(isCompleted: !sg.isCompleted);
      }
      return sg;
    }).toList();

    final updatedGoal = goal.copyWith(subGoals: subGoals);
    
    // Update in Hive using the original object's key
    updateGoal(goal.key, updatedGoal);
  }
}
