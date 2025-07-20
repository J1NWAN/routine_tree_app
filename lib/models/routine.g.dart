// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineAdapter extends TypeAdapter<Routine> {
  @override
  final int typeId = 0;

  @override
  Routine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Routine(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      emoji: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isActive: fields[5] as bool,
      type: fields[6] as RoutineType,
      weekdays: (fields[7] as List).cast<int>(),
      reminderTime: fields[8] as DateTime?,
      currentStreak: fields[9] as int,
      bestStreak: fields[10] as int,
      totalCompleted: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Routine obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.weekdays)
      ..writeByte(8)
      ..write(obj.reminderTime)
      ..writeByte(9)
      ..write(obj.currentStreak)
      ..writeByte(10)
      ..write(obj.bestStreak)
      ..writeByte(11)
      ..write(obj.totalCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutineTypeAdapter extends TypeAdapter<RoutineType> {
  @override
  final int typeId = 1;

  @override
  RoutineType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RoutineType.daily;
      case 1:
        return RoutineType.weekly;
      case 2:
        return RoutineType.custom;
      default:
        return RoutineType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RoutineType obj) {
    switch (obj) {
      case RoutineType.daily:
        writer.writeByte(0);
        break;
      case RoutineType.weekly:
        writer.writeByte(1);
        break;
      case RoutineType.custom:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
