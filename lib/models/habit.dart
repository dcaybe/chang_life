class Habit {
  final String id;
  final String name;
  final bool isDone;
  Habit({required this.name, required this.id, this.isDone = false});

  Habit copyWith({String? name, bool? isDone}) {
    return Habit(
      id: id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
    );
  }
}
