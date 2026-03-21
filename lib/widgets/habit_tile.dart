import 'package:change_life/providers/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitTile extends ConsumerWidget {
  final String id;

  const HabitTile({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitProvider(id));
    return ListTile(
      title: Text(habit.name),
      leading: Checkbox(
        value: habit.isDone,
        onChanged: (_) {
          ref.read(toggleHabitProvider)(id);
        },
      ),
    );
  }
}
