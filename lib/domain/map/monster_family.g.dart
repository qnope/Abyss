// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monster_family.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonsterFamilyAdapter extends TypeAdapter<MonsterFamily> {
  @override
  final typeId = 46;

  @override
  MonsterFamily read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MonsterFamily.swarm;
      case 1:
        return MonsterFamily.armoured;
      case 2:
        return MonsterFamily.hunter;
      case 3:
        return MonsterFamily.colossus;
      default:
        return MonsterFamily.swarm;
    }
  }

  @override
  void write(BinaryWriter writer, MonsterFamily obj) {
    switch (obj) {
      case MonsterFamily.swarm:
        writer.writeByte(0);
      case MonsterFamily.armoured:
        writer.writeByte(1);
      case MonsterFamily.hunter:
        writer.writeByte(2);
      case MonsterFamily.colossus:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonsterFamilyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
