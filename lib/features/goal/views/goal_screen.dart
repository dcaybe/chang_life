import 'package:change_life/features/goal/models/goal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = [
      Goal(id: '1', title: 'Học Flutter', description: 'Hoàn thành 8 tuần'),
      Goal(id: '2', title: 'Tìm việc intern', description: 'Apply 10 công ty'),
    ];

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
