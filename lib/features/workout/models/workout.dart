class Workout {
  final String id;
  final String name;
  final String duration;
  final bool isDone;
  Workout({
    required this.id,
    required this.name,
    required this.duration,
    this.isDone = false,
  });
}
