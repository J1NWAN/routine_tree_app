// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TreeProgressAdapter extends TypeAdapter<TreeProgress> {
  @override
  final int typeId = 4;

  @override
  TreeProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TreeProgress(
      routineId: fields[0] as String,
      level: fields[1] as int,
      experience: fields[2] as int,
      experienceToNext: fields[3] as int,
      treeType: fields[4] as TreeType,
      collectedFruits: (fields[5] as List).cast<String>(),
      collectedLeaves: (fields[6] as List).cast<String>(),
      lastUpdated: fields[7] as DateTime,
      currentSeason: fields[8] as SeasonType,
    );
  }

  @override
  void write(BinaryWriter writer, TreeProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.routineId)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.experience)
      ..writeByte(3)
      ..write(obj.experienceToNext)
      ..writeByte(4)
      ..write(obj.treeType)
      ..writeByte(5)
      ..write(obj.collectedFruits)
      ..writeByte(6)
      ..write(obj.collectedLeaves)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.currentSeason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TreeTypeAdapter extends TypeAdapter<TreeType> {
  @override
  final int typeId = 5;

  @override
  TreeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TreeType.oak;
      case 1:
        return TreeType.pine;
      case 2:
        return TreeType.cherry;
      case 3:
        return TreeType.maple;
      case 4:
        return TreeType.willow;
      default:
        return TreeType.oak;
    }
  }

  @override
  void write(BinaryWriter writer, TreeType obj) {
    switch (obj) {
      case TreeType.oak:
        writer.writeByte(0);
        break;
      case TreeType.pine:
        writer.writeByte(1);
        break;
      case TreeType.cherry:
        writer.writeByte(2);
        break;
      case TreeType.maple:
        writer.writeByte(3);
        break;
      case TreeType.willow:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeasonTypeAdapter extends TypeAdapter<SeasonType> {
  @override
  final int typeId = 6;

  @override
  SeasonType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SeasonType.spring;
      case 1:
        return SeasonType.summer;
      case 2:
        return SeasonType.autumn;
      case 3:
        return SeasonType.winter;
      default:
        return SeasonType.spring;
    }
  }

  @override
  void write(BinaryWriter writer, SeasonType obj) {
    switch (obj) {
      case SeasonType.spring:
        writer.writeByte(0);
        break;
      case SeasonType.summer:
        writer.writeByte(1);
        break;
      case SeasonType.autumn:
        writer.writeByte(2);
        break;
      case SeasonType.winter:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TreeGrowthStageAdapter extends TypeAdapter<TreeGrowthStage> {
  @override
  final int typeId = 7;

  @override
  TreeGrowthStage read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TreeGrowthStage.seedling;
      case 1:
        return TreeGrowthStage.young;
      case 2:
        return TreeGrowthStage.growing;
      case 3:
        return TreeGrowthStage.mature;
      case 4:
        return TreeGrowthStage.ancient;
      default:
        return TreeGrowthStage.seedling;
    }
  }

  @override
  void write(BinaryWriter writer, TreeGrowthStage obj) {
    switch (obj) {
      case TreeGrowthStage.seedling:
        writer.writeByte(0);
        break;
      case TreeGrowthStage.young:
        writer.writeByte(1);
        break;
      case TreeGrowthStage.growing:
        writer.writeByte(2);
        break;
      case TreeGrowthStage.mature:
        writer.writeByte(3);
        break;
      case TreeGrowthStage.ancient:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeGrowthStageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
