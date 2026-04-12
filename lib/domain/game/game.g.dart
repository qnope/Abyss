// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 1;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      humanPlayerId: fields[1] as String,
      players: (fields[0] as Map).cast<String, Player>(),
      turn: fields[2] as int,
      createdAt: fields[3] as DateTime?,
      levels: (fields[4] as Map).cast<int, GameMap>(),
      status: fields[5] as GameStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.players)
      ..writeByte(1)
      ..write(obj.humanPlayerId)
      ..writeByte(2)
      ..write(obj.turn)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.levels)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
