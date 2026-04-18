import 'package:hive/hive.dart';

part 'food.g.dart';

@HiveType(typeId: 2)
class Food {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int calories;
  @HiveField(3)
  final String image;
  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.image,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json["id"],
      name: json["name"],
      calories: json["calories"],
      image: json["image"],
    );
  }
}
