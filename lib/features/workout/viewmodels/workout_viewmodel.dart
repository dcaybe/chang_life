import 'package:change_life/features/workout/models/exercise_form_data.dart';
import 'package:change_life/features/workout/models/exercise_model.dart';
import 'package:change_life/features/workout/models/workout_model.dart';
import 'package:change_life/services/workout_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutViewModel extends StateNotifier<List<WorkoutSession>> {
  final WorkoutHiveService _hiveService;

  WorkoutViewModel(this._hiveService) : super([]) {
    loadWorkouts();
    if (state.isEmpty) {
      _initDummyData();
    }
  }

  void _initDummyData() {
    // 1. Tạo các Templates (Kế hoạch tập)
    final pushTemplate = WorkoutSession(
      id: 'template_push',
      name: 'Push Day (Ngực - Vai - Tay sau)',
      dayOfWeek: 1, // Thứ 2
      exerciseLogs: [
        ExerciseLog(
          exercise: Exercise(id: 'ex_bench', name: 'Bench Press', targetMuscle: 'Chest'),
          sets: [
            WorkoutSet(weight: 50, reps: 10),
            WorkoutSet(weight: 50, reps: 10),
            WorkoutSet(weight: 50, reps: 10),
          ],
        ),
        ExerciseLog(
          exercise: Exercise(id: 'ex_ohp', name: 'Overhead Press', targetMuscle: 'Shoulders'),
          sets: [
            WorkoutSet(weight: 30, reps: 12),
            WorkoutSet(weight: 30, reps: 12),
          ],
        ),
      ],
    );

    final pullTemplate = WorkoutSession(
      id: 'template_pull',
      name: 'Pull Day (Lưng - Tay trước)',
      dayOfWeek: 3, // Thứ 4
      exerciseLogs: [
        ExerciseLog(
          exercise: Exercise(id: 'ex_row', name: 'Bent Over Row', targetMuscle: 'Back'),
          sets: [
            WorkoutSet(weight: 40, reps: 12),
            WorkoutSet(weight: 40, reps: 12),
          ],
        ),
      ],
    );

    addWorkout(pushTemplate);
    addWorkout(pullTemplate);

    // 2. Tạo Lịch sử tập luyện (History) để hiển thị biểu đồ
    // Tạo 4 tuần lịch sử cho bài Bench Press với tạ tăng dần
    for (int i = 0; i < 4; i++) {
      final date = DateTime.now().subtract(Duration(days: 28 - (i * 7)));
      final historySession = WorkoutSession(
        id: 'hist_push_$i',
        name: 'Push Day',
        dayOfWeek: 1,
        dateCompleted: date,
        exerciseLogs: [
          ExerciseLog(
            exercise: Exercise(id: 'ex_bench', name: 'Bench Press', targetMuscle: 'Chest'),
            sets: [
              WorkoutSet(weight: 40.0 + (i * 5), reps: 10, isCompleted: true),
              WorkoutSet(weight: 40.0 + (i * 5), reps: 10, isCompleted: true),
              WorkoutSet(weight: 40.0 + (i * 5), reps: 8 + (i % 2), isCompleted: true),
            ],
          ),
        ],
      );
      addWorkout(historySession);
    }
  }

  void loadWorkouts() {
    state = _hiveService.getWorkouts();
  }


  void addWorkout(WorkoutSession workout) {
    _hiveService.addWorkout(workout);
    state = [...state, workout];
  }

  /// MVVM: ViewModel dựng toàn bộ model objects từ dữ liệu thô của View.
  void createAndAddWorkout({
    required String name,
    required int dayOfWeek,
    required List<ExerciseFormData> exercises,
  }) {
    final exerciseLogs = exercises.map((ex) {
      return ExerciseLog(
        exercise: Exercise(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: ex.name,
          targetMuscle: ex.muscle.isEmpty ? 'Chung' : ex.muscle,
        ),
        sets: List.generate(
          ex.sets,
          (_) => WorkoutSet(weight: ex.weight, reps: ex.reps),
        ),
      );
    }).toList();

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      dayOfWeek: dayOfWeek,
      exerciseLogs: exerciseLogs,
    );
    addWorkout(session);
  }

  void updateWorkout(WorkoutSession workout) {
    _hiveService.updateWorkout(workout);
    state = [
      for (final w in state)
        if (w.id == workout.id) workout else w
    ];
  }

  void deleteWorkout(String id) {
    _hiveService.removeWorkout(id);
    state = state.where((w) => w.id != id).toList();
  }

  void clearAllPlannedWorkouts() {
    final planned = state.where((w) => w.dateCompleted == null).toList();
    for (var w in planned) {
      _hiveService.removeWorkout(w.id);
    }
    state = state.where((w) => w.dateCompleted != null).toList();
  }

  List<WorkoutSession> getWorkoutsForDay(int dayOfWeek) {
    return state.where((w) => w.dayOfWeek == dayOfWeek).toList();
  }

  /// Trả về lịch sử volume cho một bài tập cụ thể (đã sort theo ngày)
  /// MVVM: Logic query/filter/sort nằm trong ViewModel, View chỉ hiển thị
  List<Map<String, dynamic>> getExerciseVolumeHistory(String exerciseName) {
    final completedSessions = state
        .where((s) => s.dateCompleted != null)
        .toList()
      ..sort((a, b) => a.dateCompleted!.compareTo(b.dateCompleted!));

    final history = <Map<String, dynamic>>[];
    for (var session in completedSessions) {
      final exerciseLogs = session.exerciseLogs.where(
        (l) => l.exercise.name == exerciseName,
      );
      for (var exLog in exerciseLogs) {
        if (exLog.totalVolume > 0) {
          history.add({
            'date': session.dateCompleted!,
            'volume': exLog.totalVolume,
          });
        }
      }
    }
    return history;
  }

  /// Trả về lịch sử 1RM cao nhất cho một bài tập cụ thể (đã sort theo ngày)
  List<Map<String, dynamic>> getExercise1RMHistory(String exerciseName) {
    final completedSessions = state
        .where((s) => s.dateCompleted != null)
        .toList()
      ..sort((a, b) => a.dateCompleted!.compareTo(b.dateCompleted!));

    final history = <Map<String, dynamic>>[];
    for (var session in completedSessions) {
      final exerciseLogs = session.exerciseLogs.where(
        (l) => l.exercise.name.toLowerCase() == exerciseName.toLowerCase(),
      );
      double max1RM = 0;
      for (var exLog in exerciseLogs) {
        for (var set in exLog.sets) {
          final oneRM = set.weight * (1 + set.reps / 30);
          if (oneRM > max1RM) {
            max1RM = oneRM;
          }
        }
      }
      if (max1RM > 0) {
        history.add({
          'date': session.dateCompleted!,
          'oneRM': max1RM,
        });
      }
    }
    return history;
  }

  /// Lấy danh sách tất cả các tên bài tập đã từng tập trong lịch sử
  List<String> getCompletedExerciseNames() {
    final names = <String>{};
    for (var session in state) {
      if (session.dateCompleted != null) {
        for (var log in session.exerciseLogs) {
          names.add(log.exercise.name);
        }
      }
    }
    return names.toList()..sort();
  }

  /// Lấy danh sách bài tập phân theo nhóm cơ từ lịch sử
  Map<String, List<String>> getCompletedExercisesByMuscle() {
    final result = <String, Set<String>>{};
    for (var session in state) {
      if (session.dateCompleted != null) {
        for (var log in session.exerciseLogs) {
          final muscle = log.exercise.targetMuscle.isNotEmpty ? log.exercise.targetMuscle : 'Other';
          result.putIfAbsent(muscle, () => <String>{});
          result[muscle]!.add(log.exercise.name);
        }
      }
    }
    
    return result.map((key, value) {
      final list = value.toList()..sort();
      return MapEntry(key, list);
    });
  }
}
