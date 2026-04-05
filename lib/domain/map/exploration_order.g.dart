// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exploration_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExplorationOrderAdapter extends TypeAdapter<ExplorationOrder> {
  @override
  final int typeId = 16;

  @override
  ExplorationOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExplorationOrder(
      target: fields[0] as GridPosition,
    );
  }

  @override
  void write(BinaryWriter writer, ExplorationOrder obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.target);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExplorationOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
