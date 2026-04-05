// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingAdapter extends TypeAdapter<Building> {
  @override
  final int typeId = 5;

  @override
  Building read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Building(
      type: fields[0] as BuildingType,
      level: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Building obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
