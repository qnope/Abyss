// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terrain_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TerrainTypeAdapter extends TypeAdapter<TerrainType> {
  @override
  final int typeId = 10;

  @override
  TerrainType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TerrainType.plain;
      case 1:
        return TerrainType.reef;
      case 2:
        return TerrainType.rock;
      case 3:
        return TerrainType.fault;
      default:
        return TerrainType.plain;
    }
  }

  @override
  void write(BinaryWriter writer, TerrainType obj) {
    switch (obj) {
      case TerrainType.plain:
        writer.writeByte(0);
        break;
      case TerrainType.reef:
        writer.writeByte(1);
        break;
      case TerrainType.rock:
        writer.writeByte(2);
        break;
      case TerrainType.fault:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TerrainTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
