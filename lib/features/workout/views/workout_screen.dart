import 'package:change_life/features/workout/models/workout.dart';
import 'package:flutter/material.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = [
      Workout(id: '1', name: 'Workout 1', duration: '30 minutes'),
      Workout(id: '2', name: 'Workout 2', duration: '45 minutes'),
      Workout(id: '3', name: 'Workout 3', duration: '60 minutes'),
    ];
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return ListTile(
          title: Text(workout.name),
          trailing: Checkbox(value: false, onChanged: (value) {}),
        );
      },
    );
  }
}
