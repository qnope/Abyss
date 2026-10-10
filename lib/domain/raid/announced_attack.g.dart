// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announced_attack.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnnouncedAttackAdapter extends TypeAdapter<AnnouncedAttack> {
  @override
  final typeId = 58;

  @override
  AnnouncedAttack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnnouncedAttack(
      attackerId: fields[0] as String,
      units: (fields[1] as Map).cast<UnitType, int>(),
      arrivalTurn: (fields[2] as num).toInt(),
      seed: (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AnnouncedAttack obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.attackerId)
      ..writeByte(1)
      ..write(obj.units)
      ..writeByte(2)
      ..write(obj.arrivalTurn)
      ..writeByte(3)
      ..write(obj.seed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncedAttackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
