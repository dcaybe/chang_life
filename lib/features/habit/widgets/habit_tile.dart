import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HabitTile extends ConsumerWidget {
  final String id;

  const HabitTile({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = ref.watch(habitProvider(id).select((h) => h.isDone));
    return ListTile(
      title: Text(ref.watch(habitProvider(id)).name),
      leading: Checkbox(
        value: isDone,
        onChanged: (_) {
          ref.read(toggleHabitProvider)(id);
        },
      ),
      onTap: () {
        context.push('/habit/detail', extra: ref.read(habitProvider(id)));
      },
    );
  }
}
