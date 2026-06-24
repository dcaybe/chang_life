// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionHistoryAdapter extends TypeAdapter<NutritionHistory> {
  @override
  final int typeId = 9;

  @override
  NutritionHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionHistory(
      id: fields[0] as String,
      startDate: fields[1] as DateTime,
      endDate: fields[2] as DateTime,
      totalCalories: fields[3] as int,
      protein: fields[4] as int,
      carbs: fields[5] as int,
      fats: fields[6] as int,
      mealPlans: (fields[7] as List).cast<MealPlan>(),
    );
  }

  @override
  void write(BinaryWriter writer, NutritionHistory obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.totalCalories)
      ..writeByte(4)
      ..write(obj.protein)
      ..writeByte(5)
      ..write(obj.carbs)
      ..writeByte(6)
      ..write(obj.fats)
      ..writeByte(7)
      ..write(obj.mealPlans);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
