// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStatusAdapter extends TypeAdapter<GameStatus> {
  @override
  final int typeId = 37;

  @override
  GameStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameStatus.playing;
      case 1:
        return GameStatus.victory;
      case 2:
        return GameStatus.defeat;
      case 3:
        return GameStatus.freePlay;
      default:
        return GameStatus.playing;
    }
  }

  @override
  void write(BinaryWriter writer, GameStatus obj) {
    switch (obj) {
      case GameStatus.playing:
        writer.writeByte(0);
        break;
      case GameStatus.victory:
        writer.writeByte(1);
        break;
      case GameStatus.defeat:
        writer.writeByte(2);
        break;
      case GameStatus.freePlay:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
