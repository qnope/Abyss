// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combatant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CombatantAdapter extends TypeAdapter<Combatant> {
  @override
  final int typeId = 27;

  @override
  Combatant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Combatant(
      side: fields[0] as CombatSide,
      typeKey: fields[1] as String,
      maxHp: fields[2] as int,
      atk: fields[3] as int,
      def: fields[4] as int,
      currentHp: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Combatant obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.side)
      ..writeByte(1)
      ..write(obj.typeKey)
      ..writeByte(2)
      ..write(obj.maxHp)
      ..writeByte(3)
      ..write(obj.atk)
      ..writeByte(4)
      ..write(obj.def)
      ..writeByte(5)
      ..write(obj.currentHp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombatantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
