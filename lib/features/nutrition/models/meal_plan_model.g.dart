// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealPlanAdapter extends TypeAdapter<MealPlan> {
  @override
  final int typeId = 7;

  @override
  MealPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPlan(
      day: fields[0] as String,
      breakfast: fields[1] as String,
      lunch: fields[2] as String,
      snack: fields[3] as String,
      dinner: fields[4] as String,
      lateNight: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MealPlan obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.breakfast)
      ..writeByte(2)
      ..write(obj.lunch)
      ..writeByte(3)
      ..write(obj.snack)
      ..writeByte(4)
      ..write(obj.dinner)
      ..writeByte(5)
      ..write(obj.lateNight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
