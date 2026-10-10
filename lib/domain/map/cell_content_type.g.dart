// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell_content_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CellContentTypeAdapter extends TypeAdapter<CellContentType> {
  @override
  final typeId = 11;

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
      case 6:
        return CellContentType.volcanicKernel;
      case 7:
        return CellContentType.wreck;
      default:
        return CellContentType.empty;
    }
  }

  @override
  void write(BinaryWriter writer, CellContentType obj) {
    switch (obj) {
      case CellContentType.empty:
        writer.writeByte(0);
      case CellContentType.resourceBonus:
        writer.writeByte(1);
      case CellContentType.ruins:
        writer.writeByte(2);
      case CellContentType.monsterLair:
        writer.writeByte(3);
      case CellContentType.transitionBase:
        writer.writeByte(4);
      case CellContentType.passage:
        writer.writeByte(5);
      case CellContentType.volcanicKernel:
        writer.writeByte(6);
      case CellContentType.wreck:
        writer.writeByte(7);
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
