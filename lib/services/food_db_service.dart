import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/nutrition/models/supabase_food_model.dart';

class FoodDbService {
  final _supabase = Supabase.instance.client;

  Future<List<SupabaseFood>> fetchFoods({String? searchQuery, String? category}) async {
    try {
      var query = _supabase.from('foods').select();

      if (category != null && category.isNotEmpty && category != 'Tất cả') {
        query = query.eq('category', category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // ILIKE case-insensitive search
        query = query.ilike('name_vi', '%$searchQuery%');
      }

      // Limit to 100 for performance
      final response = await query.limit(100);

      final List<SupabaseFood> foods = [];
      for (var item in response) {
        foods.add(SupabaseFood.fromJson(item));
      }

      return foods;
    } catch (e) {
      print('Lỗi khi fetch thực phẩm: $e');
      return [];
    }
  }
}
