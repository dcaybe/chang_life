import 'package:change_life/features/workout/models/workout_model.dart';
import 'package:hive/hive.dart';

class WorkoutHiveService {
  late Box<WorkoutSession> workoutBox;

  Future<void> init() async {
    workoutBox = await Hive.openBox<WorkoutSession>('workoutBox');
  }

  void addWorkout(WorkoutSession workout) {
    workoutBox.put(workout.id, workout);
  }

  List<WorkoutSession> getWorkouts() {
    return workoutBox.values.toList();
  }

  WorkoutSession? getWorkoutById(String id) {
    return workoutBox.get(id);
  }

  void updateWorkout(WorkoutSession workout) {
    workoutBox.put(workout.id, workout);
  }

  void removeWorkout(String id) {
    workoutBox.delete(id);
  }

  List<WorkoutSession> getWorkoutsByDay(int dayOfWeek) {
    return workoutBox.values.where((w) => w.dayOfWeek == dayOfWeek).toList();
  }
}
