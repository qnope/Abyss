// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combat_side.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CombatSideAdapter extends TypeAdapter<CombatSide> {
  @override
  final int typeId = 26;

  @override
  CombatSide read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CombatSide.player;
      case 1:
        return CombatSide.monster;
      default:
        return CombatSide.player;
    }
  }

  @override
  void write(BinaryWriter writer, CombatSide obj) {
    switch (obj) {
      case CombatSide.player:
        writer.writeByte(0);
        break;
      case CombatSide.monster:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombatSideAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
