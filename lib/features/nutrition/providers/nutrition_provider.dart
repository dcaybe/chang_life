import 'package:change_life/features/nutrition/models/food_model.dart';
import 'package:change_life/features/nutrition/viewmodels/food_viewmodel.dart';
import 'package:change_life/services/api_service.dart';
import 'package:change_life/services/food_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foodHiveServiceProvider = Provider<FoodHiveService>((ref) {
  throw UnimplementedError();
});
final foodApiProvider = Provider<FoodApi>((ref) {
  return FoodApi();
});
final foodVMProvider = AsyncNotifierProvider.autoDispose<FoodViewModel, List<Food>>(
  FoodViewModel.new,
);
