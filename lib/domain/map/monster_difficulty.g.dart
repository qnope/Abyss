// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monster_difficulty.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonsterDifficultyAdapter extends TypeAdapter<MonsterDifficulty> {
  @override
  final typeId = 12;

  @override
  MonsterDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MonsterDifficulty.easy;
      case 1:
        return MonsterDifficulty.medium;
      case 2:
        return MonsterDifficulty.hard;
      default:
        return MonsterDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, MonsterDifficulty obj) {
    switch (obj) {
      case MonsterDifficulty.easy:
        writer.writeByte(0);
      case MonsterDifficulty.medium:
        writer.writeByte(1);
      case MonsterDifficulty.hard:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonsterDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
