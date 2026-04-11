// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_cell.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapCellAdapter extends TypeAdapter<MapCell> {
  @override
  final int typeId = 13;

  @override
  MapCell read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapCell(
      terrain: fields[0] as TerrainType,
      content: fields[1] as CellContentType,
      lair: fields[2] as MonsterLair?,
      collectedBy: fields[3] as String?,
      transitionBase: fields[4] as TransitionBase?,
      passageName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MapCell obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.terrain)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.lair)
      ..writeByte(3)
      ..write(obj.collectedBy)
      ..writeByte(4)
      ..write(obj.transitionBase)
      ..writeByte(5)
      ..write(obj.passageName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapCellAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
