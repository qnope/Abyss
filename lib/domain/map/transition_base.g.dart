// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transition_base.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransitionBaseAdapter extends TypeAdapter<TransitionBase> {
  @override
  final int typeId = 32;

  @override
  TransitionBase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransitionBase(
      type: fields[0] as TransitionBaseType,
      name: fields[1] as String,
      capturedBy: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransitionBase obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.capturedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransitionBaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
