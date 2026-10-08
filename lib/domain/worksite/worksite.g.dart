// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worksite.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorksiteAdapter extends TypeAdapter<Worksite> {
  @override
  final typeId = 40;

  @override
  Worksite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Worksite(
      upgrades: fields[0] == null ? 0 : (fields[0] as num).toInt(),
      research: fields[1] == null ? 0 : (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Worksite obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.upgrades)
      ..writeByte(1)
      ..write(obj.research);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorksiteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
