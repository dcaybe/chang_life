import 'package:change_life/features/nutrition/models/food_model.dart';
import 'package:hive/hive.dart';

class FoodHiveService {
  late Box<Food> foodBox;

  Future<void> init() async {
    foodBox = await Hive.openBox<Food>('foodBox');
  }

  void saveFoods(List<Food> foods) {
    foodBox.clear();
    foodBox.addAll(foods);
  }

  List<Food>? getFoods() {
    if (foodBox.isEmpty) {
      return null;
    }
    return foodBox.values.toList();
  }
}
