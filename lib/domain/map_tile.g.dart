// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_tile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapTileAdapter extends TypeAdapter<MapTile> {
  @override
  final int typeId = 12;

  @override
  MapTile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapTile(
      x: fields[0] as int,
      y: fields[1] as int,
      terrain: fields[2] as TerrainType,
      content: fields[3] as TileContent,
      revealed: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MapTile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.x)
      ..writeByte(1)
      ..write(obj.y)
      ..writeByte(2)
      ..write(obj.terrain)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.revealed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapTileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
