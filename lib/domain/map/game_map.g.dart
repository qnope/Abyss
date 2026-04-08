// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_map.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameMapAdapter extends TypeAdapter<GameMap> {
  @override
  final int typeId = 14;

  @override
  GameMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameMap(
      width: fields[0] as int,
      height: fields[1] as int,
      cells: (fields[2] as List).cast<MapCell>(),
      seed: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameMap obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.width)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.cells)
      ..writeByte(5)
      ..write(obj.seed);
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
