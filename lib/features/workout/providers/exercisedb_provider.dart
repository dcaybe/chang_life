import 'package:change_life/features/workout/models/exercisedb_model.dart';
import 'package:change_life/services/exercisedb_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider cho ExerciseDbService singleton
final exerciseDbServiceProvider = Provider<ExerciseDbService>((ref) {
  return ExerciseDbService();
});

/// Provider lấy danh sách body parts (nhóm cơ lớn) — cache kết quả
final bodyPartsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(exerciseDbServiceProvider);
  return service.fetchBodyParts();
});

/// Provider tìm kiếm bài tập — params = {name, bodyPart}
/// Dùng family để mỗi combo (name, bodyPart) có state riêng.
final exerciseSearchProvider =
    FutureProvider.family<ExerciseDbResponse, ExerciseSearchParams>((
      ref,
      params,
    ) async {
      final service = ref.read(exerciseDbServiceProvider);
      return service.searchExercises(
        name: params.name,
        bodyPart: params.bodyPart,
        limit: params.limit,
      );
    });

/// Immutable params cho exerciseSearchProvider
class ExerciseSearchParams {
  final String? name;
  final String? bodyPart;
  final int limit;

  const ExerciseSearchParams({this.name, this.bodyPart, this.limit = 20});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSearchParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          bodyPart == other.bodyPart &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(name, bodyPart, limit);
}
