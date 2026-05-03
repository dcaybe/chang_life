/// Data class truyền dữ liệu thô từ View sang ViewModel.
/// Không chứa bất kỳ Hive object hay business logic nào.
/// Thuộc tầng Model theo MVVM.
class ExerciseFormData {
  final String name;
  final String muscle;
  final int sets;
  final double weight;
  final int reps;

  const ExerciseFormData({
    required this.name,
    required this.muscle,
    required this.sets,
    required this.weight,
    required this.reps,
  });
}
