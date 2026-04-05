// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_position.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GridPositionAdapter extends TypeAdapter<GridPosition> {
  @override
  final int typeId = 15;

  @override
  GridPosition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GridPosition(
      x: fields[0] as int,
      y: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GridPosition obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.x)
      ..writeByte(1)
      ..write(obj.y);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
