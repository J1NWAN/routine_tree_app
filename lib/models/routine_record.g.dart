// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineRecordAdapter extends TypeAdapter<RoutineRecord> {
  @override
  final int typeId = 2;

  @override
  RoutineRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineRecord(
      id: fields[0] as String,
      routineId: fields[1] as String,
      date: fields[2] as DateTime,
      completedAt: fields[3] as DateTime,
      note: fields[4] as String?,
      status: fields[5] as RecordStatus,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.routineId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.completedAt)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecordStatusAdapter extends TypeAdapter<RecordStatus> {
  @override
  final int typeId = 3;

  @override
  RecordStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecordStatus.completed;
      case 1:
        return RecordStatus.skipped;
      case 2:
        return RecordStatus.failed;
      default:
        return RecordStatus.completed;
    }
  }

  @override
  void write(BinaryWriter writer, RecordStatus obj) {
    switch (obj) {
      case RecordStatus.completed:
        writer.writeByte(0);
        break;
      case RecordStatus.skipped:
        writer.writeByte(1);
        break;
      case RecordStatus.failed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
