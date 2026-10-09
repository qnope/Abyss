// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monster_lair.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonsterLairAdapter extends TypeAdapter<MonsterLair> {
  @override
  final typeId = 17;

  @override
  MonsterLair read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonsterLair(
      difficulty: fields[0] as MonsterDifficulty,
      unitCount: (fields[1] as num).toInt(),
      family: fields[2] as MonsterFamily?,
      secondFamily: fields[3] as MonsterFamily?,
      secondCount: fields[4] == null ? 0 : (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MonsterLair obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.difficulty)
      ..writeByte(1)
      ..write(obj.unitCount)
      ..writeByte(2)
      ..write(obj.family)
      ..writeByte(3)
      ..write(obj.secondFamily)
      ..writeByte(4)
      ..write(obj.secondCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonsterLairAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
