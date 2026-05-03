import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 8)
class SubGoal {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final bool isCompleted;

  SubGoal({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubGoal copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@HiveType(typeId: 0)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime deadline;
  @HiveField(4)
  final List<SubGoal> subGoals;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.subGoals,
  });

  double get progress {
    if (subGoals.isEmpty) return 0;
    final completedCount = subGoals.where((s) => s.isCompleted).length;
    return completedCount / subGoals.length;
  }

  int get remainingDays {
    final diff = deadline.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  Goal copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    List<SubGoal>? subGoals,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      subGoals: subGoals ?? this.subGoals,
    );
  }
}
