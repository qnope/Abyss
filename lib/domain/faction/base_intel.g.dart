// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_intel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BaseIntelAdapter extends TypeAdapter<BaseIntel> {
  @override
  final typeId = 59;

  @override
  BaseIntel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BaseIntel(
      turn: (fields[0] as num).toInt(),
      headquartersLevel: (fields[1] as num).toInt(),
      rampartLevel: (fields[2] as num).toInt(),
      army: (fields[3] as Map).cast<UnitType, int>(),
      stocks: (fields[4] as Map).cast<ResourceType, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, BaseIntel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.headquartersLevel)
      ..writeByte(2)
      ..write(obj.rampartLevel)
      ..writeByte(3)
      ..write(obj.army)
      ..writeByte(4)
      ..write(obj.stocks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseIntelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
