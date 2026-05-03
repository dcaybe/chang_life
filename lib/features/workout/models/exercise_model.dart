import 'package:hive/hive.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 4)
class Exercise {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;

  @HiveField(2)
  final String targetMuscle;

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
  });
}

@HiveType(typeId: 5)
class WorkoutSet {
  @HiveField(0)
  double weight;

  @HiveField(1)
  int reps;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  bool? isPR;

  WorkoutSet({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
    this.isPR = false,
  });

  WorkoutSet copyWith({
    double? weight,
    int? reps,
    bool? isCompleted,
    bool? isPR,
  }) {
    return WorkoutSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
      isPR: isPR ?? this.isPR,
    );
  }
}

@HiveType(typeId: 6)
class ExerciseLog {
  @HiveField(0)
  final Exercise exercise;

  @HiveField(1)
  List<WorkoutSet> sets;

  @HiveField(2)
  String notes;

  /// Thời gian nghỉ giữa các hiệp (giây). Mặc định 60s.
  @HiveField(3)
  int? restSeconds;

  ExerciseLog({
    required this.exercise,
    required this.sets,
    this.notes = '',
    this.restSeconds = 60,
  });

  double get highest1RM {
    double max1RM = 0;
    for (var s in sets) {
      if (s.isCompleted) {
        double current1RM = s.weight * (1 + s.reps / 30);
        if (current1RM > max1RM) max1RM = current1RM;
      }
    }
    return max1RM;
  }

  double get totalVolume {
    double vol = 0;
    for (var s in sets) {
      if (s.isCompleted) {
        vol += s.weight * s.reps;
      }
    }
    return vol;
  }

  ExerciseLog copyWith({
    Exercise? exercise,
    List<WorkoutSet>? sets,
    String? notes,
    int? restSeconds,
  }) {
    return ExerciseLog(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}
