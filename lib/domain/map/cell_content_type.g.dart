// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell_content_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CellContentTypeAdapter extends TypeAdapter<CellContentType> {
  @override
  final int typeId = 11;

  @override
  CellContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CellContentType.empty;
      case 1:
        return CellContentType.resourceBonus;
      case 2:
        return CellContentType.ruins;
      case 3:
        return CellContentType.monsterLair;
      case 4:
        return CellContentType.transitionBase;
      case 5:
        return CellContentType.passage;
      default:
        return CellContentType.empty;
    }
  }

  @override
  void write(BinaryWriter writer, CellContentType obj) {
    switch (obj) {
      case CellContentType.empty:
        writer.writeByte(0);
        break;
      case CellContentType.resourceBonus:
        writer.writeByte(1);
        break;
      case CellContentType.ruins:
        writer.writeByte(2);
        break;
      case CellContentType.monsterLair:
        writer.writeByte(3);
        break;
      case CellContentType.transitionBase:
        writer.writeByte(4);
        break;
      case CellContentType.passage:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
