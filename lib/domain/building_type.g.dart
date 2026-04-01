// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingTypeAdapter extends TypeAdapter<BuildingType> {
  @override
  final int typeId = 4;

  @override
  BuildingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuildingType.headquarters;
      default:
        return BuildingType.headquarters;
    }
  }

  @override
  void write(BinaryWriter writer, BuildingType obj) {
    switch (obj) {
      case BuildingType.headquarters:
        writer.writeByte(0);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
