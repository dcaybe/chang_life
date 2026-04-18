import 'package:change_life/features/goal/models/goal_model.dart';
import 'package:hive/hive.dart';

class GoalHiveService {
  late Box<Goal> goalBox;

  Future<void> init() async {
    goalBox = await Hive.openBox<Goal>('goalBox');
  }

  void addGoal(Goal goal) {
    goalBox.add(goal);
  }

  List<Goal> getGoals() {
    if (goalBox.isEmpty) {
      return [
        Goal(id: '1', title: 'Học Flutter', description: 'Hoàn thành 8 tuần'),
        Goal(
          id: '2',
          title: 'Tìm việc intern',
          description: 'Apply 10 công ty',
        ),
      ];
    }
    return goalBox.values.toList();
  }

  void removeGoal(int index) {
    goalBox.deleteAt(index);
  }

  Box<Goal> getBox() {
    return goalBox;
  }
}
