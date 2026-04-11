import 'package:change_life/features/habit/models/habit.dart';
import 'package:flutter/material.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Detail')),
      body: Center(
        child: Column(
          children: [
            Text(habit.name),
            SizedBox(height: 20),
            Text(habit.isDone ? 'Done' : 'Not Done'),
          ],
        ),
      ),
    );
  }
}
