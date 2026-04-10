// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reinforcement_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReinforcementOrderAdapter extends TypeAdapter<ReinforcementOrder> {
  @override
  final int typeId = 33;

  @override
  ReinforcementOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReinforcementOrder(
      fromLevel: fields[0] as int,
      toLevel: fields[1] as int,
      units: (fields[2] as Map).cast<UnitType, int>(),
      departTurn: fields[3] as int,
      arrivalPoint: fields[4] as GridPosition,
    );
  }

  @override
  void write(BinaryWriter writer, ReinforcementOrder obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fromLevel)
      ..writeByte(1)
      ..write(obj.toLevel)
      ..writeByte(2)
      ..write(obj.units)
      ..writeByte(3)
      ..write(obj.departTurn)
      ..writeByte(4)
      ..write(obj.arrivalPoint);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReinforcementOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
