// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitTypeAdapter extends TypeAdapter<UnitType> {
  @override
  final int typeId = 6;

  @override
  UnitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UnitType.scout;
      case 1:
        return UnitType.harpoonist;
      case 2:
        return UnitType.guardian;
      case 3:
        return UnitType.domeBreaker;
      case 4:
        return UnitType.siphoner;
      case 5:
        return UnitType.saboteur;
      default:
        return UnitType.scout;
    }
  }

  @override
  void write(BinaryWriter writer, UnitType obj) {
    switch (obj) {
      case UnitType.scout:
        writer.writeByte(0);
        break;
      case UnitType.harpoonist:
        writer.writeByte(1);
        break;
      case UnitType.guardian:
        writer.writeByte(2);
        break;
      case UnitType.domeBreaker:
        writer.writeByte(3);
        break;
      case UnitType.siphoner:
        writer.writeByte(4);
        break;
      case UnitType.saboteur:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
