/// Model cho dữ liệu bài tập từ ExerciseDB API (oss.exercisedb.dev)
/// Không dùng Hive — chỉ dùng cho hiển thị & chọn bài tập trong dialog.
class ExerciseDbItem {
  final String exerciseId;
  final String name;
  final String gifUrl;
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  const ExerciseDbItem({
    required this.exerciseId,
    required this.name,
    required this.gifUrl,
    required this.bodyParts,
    required this.equipments,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory ExerciseDbItem.fromJson(Map<String, dynamic> json) {
    return ExerciseDbItem(
      exerciseId: json['exerciseId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gifUrl: json['gifUrl'] as String? ?? '',
      bodyParts: _toStringList(json['bodyParts']),
      equipments: _toStringList(json['equipments']),
      targetMuscles: _toStringList(json['targetMuscles']),
      secondaryMuscles: _toStringList(json['secondaryMuscles']),
      instructions: _toStringList(json['instructions']),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Trả về chuỗi nhóm cơ chính (dùng cho Hive Exercise.targetMuscle)
  String get primaryMuscle =>
      targetMuscles.isNotEmpty ? targetMuscles.first : (bodyParts.isNotEmpty ? bodyParts.first : 'General');

  /// Trả về chuỗi dụng cụ
  String get equipment => equipments.isNotEmpty ? equipments.first : 'N/A';
}

/// Response wrapper cho ExerciseDB API
class ExerciseDbResponse {
  final bool success;
  final int total;
  final bool hasNextPage;
  final String? nextCursor;
  final List<ExerciseDbItem> data;

  const ExerciseDbResponse({
    required this.success,
    required this.total,
    required this.hasNextPage,
    this.nextCursor,
    required this.data,
  });

  factory ExerciseDbResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final dataList = json['data'] as List? ?? [];
    return ExerciseDbResponse(
      success: json['success'] as bool? ?? false,
      total: meta['total'] as int? ?? 0,
      hasNextPage: meta['hasNextPage'] as bool? ?? false,
      nextCursor: meta['nextCursor'] as String?,
      data: dataList.map((e) => ExerciseDbItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
