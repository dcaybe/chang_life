import 'package:change_life/features/goal/models/goal.dart';
import 'package:hive/hive.dart';

class HiveService {
  late Box<Goal> goalBox;

  Future<void> init() async {
    goalBox = await Hive.openBox<Goal>('goalBox');
  }

  void addHabit(Goal habit) {
    goalBox.add(habit);
  }

  List<Goal> getHabits() {
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

  Box<Goal> getBox() {
    return goalBox;
  }
}
