part of 'player.dart';

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return Player(name: fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }
}
