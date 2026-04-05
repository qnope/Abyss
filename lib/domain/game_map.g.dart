// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_map.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameMapAdapter extends TypeAdapter<GameMap> {
  @override
  final int typeId = 13;

  @override
  GameMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameMap(
      tiles: (fields[0] as List).cast<MapTile>(),
      width: fields[1] as int,
      height: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameMap obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tiles)
      ..writeByte(1)
      ..write(obj.width)
      ..writeByte(2)
      ..write(obj.height);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
