part of 'game.dart';

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 1;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return Game(
      player: fields[0] as Player,
      turn: fields[1] as int,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.player)
      ..writeByte(1)
      ..write(obj.turn)
      ..writeByte(2)
      ..write(obj.createdAt);
  }
}
