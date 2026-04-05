// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_content.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileContentAdapter extends TypeAdapter<TileContent> {
  @override
  final int typeId = 11;

  @override
  TileContent read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TileContent.empty;
      case 1:
        return TileContent.playerBase;
      case 2:
        return TileContent.monsterLevel1;
      case 3:
        return TileContent.monsterLevel2;
      case 4:
        return TileContent.monsterLevel3;
      case 5:
        return TileContent.enemy;
      default:
        return TileContent.empty;
    }
  }

  @override
  void write(BinaryWriter writer, TileContent obj) {
    switch (obj) {
      case TileContent.empty:
        writer.writeByte(0);
        break;
      case TileContent.playerBase:
        writer.writeByte(1);
        break;
      case TileContent.monsterLevel1:
        writer.writeByte(2);
        break;
      case TileContent.monsterLevel2:
        writer.writeByte(3);
        break;
      case TileContent.monsterLevel3:
        writer.writeByte(4);
        break;
      case TileContent.enemy:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
