import 'package:change_life/features/goal/models/goal.dart';
import 'package:change_life/features/goal/provider/goal_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalProviders = ref.watch(hiveServiceProvider);
    final goals = goalProviders.getHabits();
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView.builder(
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return ListTile(
            title: Text(goal.title),
            trailing: Checkbox(value: goal.isCompleted, onChanged: (value) {}),
            onTap: () {
              context.push('/goal/detail', extra: goal);
            },
          );
        },
      ),
    );
  }
}
