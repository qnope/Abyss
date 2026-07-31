// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turn_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TurnResourceChangeAdapter extends TypeAdapter<TurnResourceChange> {
  @override
  final typeId = 30;

  @override
  TurnResourceChange read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TurnResourceChange(
      type: fields[0] as ResourceType,
      produced: (fields[1] as num).toInt(),
      consumed: fields[2] == null ? 0 : (fields[2] as num).toInt(),
      wasCapped: fields[3] as bool,
      beforeAmount: (fields[4] as num).toInt(),
      afterAmount: (fields[5] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, TurnResourceChange obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.produced)
      ..writeByte(2)
      ..write(obj.consumed)
      ..writeByte(3)
      ..write(obj.wasCapped)
      ..writeByte(4)
      ..write(obj.beforeAmount)
      ..writeByte(5)
      ..write(obj.afterAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurnResourceChangeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
