import 'package:hive/hive.dart';
import 'exercise_model.dart';
part 'workout_model.g.dart';

@HiveType(typeId: 3)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int dayOfWeek; // 1 = Monday, 7 = Sunday

  @HiveField(3)
  List<ExerciseLog> exerciseLogs;

  @HiveField(4)
  DateTime? dateCompleted;

  WorkoutSession({
    required this.id,
    required this.name,
    required this.dayOfWeek,
    required this.exerciseLogs,
    this.dateCompleted,
  });

  bool get isCompleted => dateCompleted != null;

  WorkoutSession copyWith({
    String? id,
    String? name,
    int? dayOfWeek,
    List<ExerciseLog>? exerciseLogs,
    DateTime? dateCompleted,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      name: name ?? this.name,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      dateCompleted: dateCompleted ?? this.dateCompleted,
    );
  }
}
