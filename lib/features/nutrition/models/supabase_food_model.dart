class SupabaseFood {
  final String id;
  final String code;
  final String nameVi;
  final String nameEn;
  final String category;
  final double? energy;
  final double? protein;
  final double? fat;
  final double? carb;

  SupabaseFood({
    required this.id,
    required this.code,
    required this.nameVi,
    required this.nameEn,
    required this.category,
    this.energy,
    this.protein,
    this.fat,
    this.carb,
  });

  factory SupabaseFood.fromJson(Map<String, dynamic> json) {
    return SupabaseFood(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      nameVi: json['name_vi'] ?? '',
      nameEn: json['name_en'] ?? '',
      category: json['category'] ?? '',
      energy: json['energy'] != null ? double.tryParse(json['energy'].toString()) : null,
      protein: json['protein'] != null ? double.tryParse(json['protein'].toString()) : null,
      fat: json['fat'] != null ? double.tryParse(json['fat'].toString()) : null,
      carb: json['carb'] != null ? double.tryParse(json['carb'].toString()) : null,
    );
  }
}
