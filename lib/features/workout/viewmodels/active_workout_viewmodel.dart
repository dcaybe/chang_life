import 'dart:async';
import 'package:change_life/features/workout/models/exercise_model.dart';
import 'package:change_life/features/workout/models/workout_model.dart';
import 'package:change_life/services/workout_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveWorkoutState {
  final WorkoutSession? session;
  final int restTimerSeconds;
  final bool isTimerActive;
  final bool isEditMode;
  /// ID của buổi tập gốc (template) — dùng để xóa khỏi danh sách
  final String? templateId;
  /// Thời gian đã tập (giây) — chạy liên tục từ khi startSession()
  final int elapsedSeconds;
  /// Thời điểm bắt đầu buổi tập
  final DateTime? startTime;

  ActiveWorkoutState({
    this.session,
    this.restTimerSeconds = 0,
    this.isTimerActive = false,
    this.isEditMode = false,
    this.templateId,
    this.elapsedSeconds = 0,
    this.startTime,
  });

  ActiveWorkoutState copyWith({
    WorkoutSession? session,
    int? restTimerSeconds,
    bool? isTimerActive,
    bool? isEditMode,
    String? templateId,
    int? elapsedSeconds,
    DateTime? startTime,
  }) {
    return ActiveWorkoutState(
      session: session ?? this.session,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      isEditMode: isEditMode ?? this.isEditMode,
      templateId: templateId ?? this.templateId,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startTime: startTime ?? this.startTime,
    );
  }

  /// True khi tất cả set trong tất cả bài đều đã được tick hoàn thành.
  bool get allSetsCompleted {
    if (session == null || session!.exerciseLogs.isEmpty) return false;
    return session!.exerciseLogs.every(
      (log) => log.sets.isNotEmpty && log.sets.every((s) => s.isCompleted),
    );
  }

  /// True khi user đã tick ít nhất 1 set (có tiến trình tập)
  bool get hasProgress {
    if (session == null) return false;
    return session!.exerciseLogs.any(
      (log) => log.sets.any((s) => s.isCompleted),
    );
  }

  /// Format thời gian elapsed thành HH:MM:SS hoặc MM:SS
  String get elapsedFormatted {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Trả về session hiện tại được gán lại id gốc — dùng để lưu template.
  WorkoutSession? get editedTemplate {
    if (session == null || templateId == null) return null;
    return session!.copyWith(id: templateId!, dateCompleted: null);
  }
}


class ActiveWorkoutViewModel extends StateNotifier<ActiveWorkoutState> {
  final WorkoutHiveService _hiveService;
  final void Function(WorkoutSession) onWorkoutCompleted;
  final void Function(WorkoutSession)? onUpdateTemplate;
  Timer? _timer;
  Timer? _elapsedTimer; // Timer đếm thời gian tập

  ActiveWorkoutViewModel(this._hiveService, {required this.onWorkoutCompleted, this.onUpdateTemplate}) : super(ActiveWorkoutState());

  void startSession(WorkoutSession template) {
    // Dừng timer cũ nếu có
    _elapsedTimer?.cancel();
    _timer?.cancel();

    // Clone template sang session mới, giữ lại templateId để hỗ trợ xóa
    final liveSession = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateCompleted: null,
      exerciseLogs: template.exerciseLogs.map((log) => log.copyWith(
        sets: log.sets.map((s) => s.copyWith(isCompleted: false, isPR: false)).toList()
      )).toList(),
    );
    state = state.copyWith(
      session: liveSession,
      templateId: template.id,
      elapsedSeconds: 0,
      startTime: DateTime.now(),
    );

    // Bắt đầu đếm thời gian tập (chỉ khi không phải edit mode)
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isEditMode && state.session != null) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void toggleSet(int exerciseIndex, int setIndex) {
    if (state.session == null) return;

    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    final log = logs[exerciseIndex];
    final sets = List<WorkoutSet>.from(log.sets);
    final set = sets[setIndex];

    final newStatus = !set.isCompleted;
    
    // Kiểm tra PR khi đánh dấu hoàn thành
    bool isPR = false;
    if (newStatus) {
      isPR = _checkIfPR(log.exercise.name, set.weight, set.reps);
    }

    sets[setIndex] = set.copyWith(isCompleted: newStatus, isPR: isPR);
    logs[exerciseIndex] = log.copyWith(sets: sets);

    state = state.copyWith(
      session: state.session!.copyWith(exerciseLogs: logs),
    );

    if (newStatus) {
      // Dùng restSeconds của bài tập thay vì hardcoded (mặc định 60s)
      startRestTimer(log.restSeconds ?? 60);
    }
  }

  bool _checkIfPR(String exerciseName, double weight, int reps) {
    final allSessions = _hiveService.getWorkouts();
    final completedSessions = allSessions.where((s) => s.dateCompleted != null).toList();
    
    if (completedSessions.isEmpty) return weight > 0;

    double current1RM = weight * (1 + reps / 30);
    double maxWeight = 0;
    double max1RM = 0;
    
    for (var session in completedSessions) {
      for (var log in session.exerciseLogs) {
        if (log.exercise.name == exerciseName) {
          for (var s in log.sets) {
            if (s.isCompleted) {
              if (s.weight > maxWeight) maxWeight = s.weight;
              double hist1RM = s.weight * (1 + s.reps / 30);
              if (hist1RM > max1RM) max1RM = hist1RM;
            }
          }
        }
      }
    }
    
    // Là PR nếu tạ nặng hơn kỷ lục cũ HOẶC 1RM cao hơn kỷ lục cũ
    return (weight > maxWeight || current1RM > max1RM) && weight > 0;
  }

  void updateSet(int exerciseIndex, int setIndex, double weight, int reps) {
    if (state.session == null) return;

    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    final log = logs[exerciseIndex];
    final sets = List<WorkoutSet>.from(log.sets);

    sets[setIndex] = sets[setIndex].copyWith(weight: weight, reps: reps);
    logs[exerciseIndex] = log.copyWith(sets: sets);

    state = state.copyWith(
      session: state.session!.copyWith(exerciseLogs: logs),
    );
  }

  /// Cập nhật thời gian nghỉ của bài tập (Edit Mode)
  void updateRestTime(int exerciseIndex, int seconds) {
    if (state.session == null) return;
    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    logs[exerciseIndex] = logs[exerciseIndex].copyWith(restSeconds: seconds);
    state = state.copyWith(session: state.session!.copyWith(exerciseLogs: logs));
  }

  void startRestTimer(int seconds) {
    _timer?.cancel();
    state = state.copyWith(restTimerSeconds: seconds, isTimerActive: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restTimerSeconds > 0) {
        state = state.copyWith(restTimerSeconds: state.restTimerSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(isTimerActive: false);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerActive: false, restTimerSeconds: 0);
  }

  void addSet(int exerciseIndex) {
    if (state.session == null) return;
    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    final log = logs[exerciseIndex];
    final sets = List<WorkoutSet>.from(log.sets);

    // Lấy thông số của hiệp cuối cùng làm mặc định cho hiệp mới
    final lastSet = sets.isNotEmpty ? sets.last : WorkoutSet(weight: 0, reps: 0);
    sets.add(lastSet.copyWith(isCompleted: false));

    logs[exerciseIndex] = log.copyWith(sets: sets);
    state = state.copyWith(session: state.session!.copyWith(exerciseLogs: logs));
  }

  void toggleEditMode() {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }

  void addExercise(Exercise exercise) {
    if (state.session == null) return;
    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    logs.add(ExerciseLog(
      exercise: exercise,
      sets: [WorkoutSet(weight: 0, reps: 0)],
    ));
    state = state.copyWith(session: state.session!.copyWith(exerciseLogs: logs));
  }

  void addExerciseLog(ExerciseLog log) {
    if (state.session == null) return;
    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    logs.add(log);
    state = state.copyWith(session: state.session!.copyWith(exerciseLogs: logs));
  }

  /// MVVM: ViewModel dựng ExerciseLog từ dữ liệu thô, View chỉ truyền params.
  void createAndAddExercise({
    required String name,
    required String muscle,
    required int sets,
    required double weight,
    required int reps,
  }) {
    final log = ExerciseLog(
      exercise: Exercise(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        targetMuscle: muscle.isEmpty ? 'Chung' : muscle,
      ),
      sets: List.generate(sets, (_) => WorkoutSet(weight: weight, reps: reps)),
    );
    addExerciseLog(log);
  }

  void deleteExercise(int exerciseIndex) {
    if (state.session == null) return;
    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    logs.removeAt(exerciseIndex);
    state = state.copyWith(session: state.session!.copyWith(exerciseLogs: logs));
  }

  void renameExercise(int exerciseIndex, String newName) {
    if (state.session == null) return;
    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    final log = logs[exerciseIndex];
    final exercise = log.exercise;
    
    final updatedExercise = Exercise(
      id: exercise.id,
      name: newName,
      targetMuscle: exercise.targetMuscle,
    );
    
    logs[exerciseIndex] = log.copyWith(exercise: updatedExercise);
    state = state.copyWith(session: state.session!.copyWith(exerciseLogs: logs));
  }

  void updateExerciseNote(int exerciseIndex, String note) {
    if (state.session == null) return;
    final logs = List<ExerciseLog>.from(state.session!.exerciseLogs);
    final log = logs[exerciseIndex];
    logs[exerciseIndex] = log.copyWith(notes: note);
    state = state.copyWith(session: state.session!.copyWith(exerciseLogs: logs));
  }

  void finishSession() {

    if (state.session == null) return;
    
    // Dừng tất cả timer
    _timer?.cancel();
    _elapsedTimer?.cancel();

    final completedSession = state.session!.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      dateCompleted: DateTime.now(),
    );
    
    // Gọi callback để update state global, thay vì ghi trực tiếp vào hive mà không update state
    onWorkoutCompleted(completedSession);

    // Cập nhật lại template gốc để lưu lại các note hoặc thay đổi set
    if (onUpdateTemplate != null && state.editedTemplate != null) {
      onUpdateTemplate!(state.editedTemplate!);
    }

    state = ActiveWorkoutState(); 
  }

  /// Huỷ buổi tập — dừng timer, reset state
  void cancelSession() {
    _timer?.cancel();
    _elapsedTimer?.cancel();
    state = ActiveWorkoutState();
  }


  @override
  void dispose() {
    _timer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }
}
