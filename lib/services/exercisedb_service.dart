import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:change_life/features/workout/models/exercisedb_model.dart';

/// Service gọi dữ liệu bài tập từ Supabase (đã dịch sang tiếng Việt)
class ExerciseDbService {
  final _supabase = Supabase.instance.client;

  Future<List<String>> fetchBodyParts() async {
    final res = await _supabase.from('exercises').select('body_part');
    final Set<String> parts = {};
    for (var row in res) {
      if (row['body_part'] != null && row['body_part'].toString().isNotEmpty) {
        parts.add(row['body_part'].toString());
      }
    }
    return parts.toList();
  }

  Future<List<String>> fetchMuscles() async {
    final res = await _supabase.from('exercises').select('target');
    final Set<String> muscles = {};
    for (var row in res) {
      if (row['target'] != null && row['target'].toString().isNotEmpty) {
        muscles.add(row['target'].toString());
      }
    }
    return muscles.toList();
  }

  Future<ExerciseDbResponse> searchExercises({
    String? name,
    String? bodyPart,
    int limit = 20,
    String? cursor,
  }) async {
    var query = _supabase.from('exercises').select();

    if (name != null && name.trim().isNotEmpty) {
      // Tìm kiếm tiếng Việt hoặc tiếng Anh
      query = query.or(
        'name_vi.ilike.%${name.trim()}%,name_en.ilike.%${name.trim()}%',
      );
    }
    if (bodyPart != null && bodyPart.isNotEmpty) {
      query = query.eq('body_part', bodyPart);
    }

    // Xử lý cursor đơn giản bằng offset (nếu cần, nhưng tạm thời limit)
    int offset = 0;
    if (cursor != null && cursor.isNotEmpty) {
      offset = int.tryParse(cursor) ?? 0;
    }

    final data = await query.range(offset, offset + limit - 1);

    // Chuyển đổi dữ liệu Supabase sang format ExerciseDbResponse
    final List<ExerciseDbItem> items = data.map((row) {
      return ExerciseDbItem.fromJson({
        'exerciseId': row['id'],
        'name': row['name_en'] ?? row['name_vi'],
        'gifUrl': row['gif_url'],
        'bodyParts': [row['body_part']],
        'equipments': [row['equipment']],
        'targetMuscles': [row['target']],
        'secondaryMuscles': row['secondary_muscles'] ?? [],
        'instructions': row['instructions_vi'] ?? row['instructions_en'] ?? [],
      });
    }).toList();

    return ExerciseDbResponse(
      success: true,
      total: items.length, // Tạm thời
      hasNextPage: items.length == limit,
      nextCursor: items.length == limit ? (offset + limit).toString() : null,
      data: items,
    );
  }
}
