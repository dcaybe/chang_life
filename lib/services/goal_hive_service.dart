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
      final initialData = [
        Goal(
          id: '1',
          title: 'Học Flutter nâng cao',
          description: 'Làm chủ Riverpod và Clean Architecture',
          deadline: DateTime.now().add(const Duration(days: 30)),
          subGoals: [
            SubGoal(id: '1a', title: 'Học Provider/Riverpod', isCompleted: true),
            SubGoal(id: '1b', title: 'Xây dựng module Goal', isCompleted: false),
            SubGoal(id: '1c', title: 'Triển khai Hive Database', isCompleted: false),
          ],
        ),
        Goal(
          id: '2',
          title: 'Xây dựng Portfolio',
          description: 'Chuẩn bị cho kỳ thực tập sắp tới',
          deadline: DateTime.now().add(const Duration(days: 60)),
          subGoals: [
            SubGoal(id: '2a', title: 'Thiết kế UI trên Figma', isCompleted: false),
            SubGoal(id: '2b', title: 'Viết CV chuyên nghiệp', isCompleted: false),
          ],
        ),
      ];
      // Save initial data to box so they get keys
      goalBox.addAll(initialData);
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
