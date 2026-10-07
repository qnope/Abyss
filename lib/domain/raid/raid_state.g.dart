// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raid_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RaidStateAdapter extends TypeAdapter<RaidState> {
  @override
  final typeId = 38;

  @override
  RaidState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RaidState(
      noise: fields[0] == null ? 0 : (fields[0] as num).toInt(),
      totalNoise: fields[1] == null ? 0 : (fields[1] as num).toInt(),
      incoming: fields[2] as MonsterLair?,
      arrivalTurn: (fields[3] as num?)?.toInt(),
      lostInARow: fields[4] == null ? 0 : (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, RaidState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.noise)
      ..writeByte(1)
      ..write(obj.totalNoise)
      ..writeByte(2)
      ..write(obj.incoming)
      ..writeByte(3)
      ..write(obj.arrivalTurn)
      ..writeByte(4)
      ..write(obj.lostInARow);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaidStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
