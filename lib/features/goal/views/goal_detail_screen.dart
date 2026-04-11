import 'package:change_life/features/goal/models/goal.dart';
import 'package:flutter/material.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goal Detail')),
      body: const Center(child: Text('Goal Detail')),
    );
  }
}
