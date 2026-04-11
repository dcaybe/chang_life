import 'package:change_life/features/nutrition/models/food.dart';
import 'package:flutter/material.dart';

class NutritionDetailScreen extends StatelessWidget {
  final Food food;
  const NutritionDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: Center(
        child: Column(
          children: [
            Image.network(food.image),
            Text(food.name),
            Text(food.calories.toString()),
          ],
        ),
      ),
    );
  }
}
