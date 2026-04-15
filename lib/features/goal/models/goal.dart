import 'package:hive/hive.dart';

// Đây là thông báo để sinh file Adapter
part 'goal.g.dart'; 

// Đánh số typeId duy nhất cho Class này (0 đến 255)
@HiveType(typeId: 0) 
class Goal extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final bool isCompleted;

  Goal({
    required this.id, 
    required this.title, 
    required this.description, 
    this.isCompleted = false
  });
}
