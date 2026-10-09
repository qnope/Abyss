// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volcano_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VolcanoStateAdapter extends TypeAdapter<VolcanoState> {
  @override
  final typeId = 47;

  @override
  VolcanoState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VolcanoState(
      incoming: fields[0] as MonsterLair?,
      arrivalTurn: (fields[1] as num?)?.toInt(),
      wavesRepelled: fields[2] == null ? 0 : (fields[2] as num).toInt(),
      levelsLost: fields[3] == null ? 0 : (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, VolcanoState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.incoming)
      ..writeByte(1)
      ..write(obj.arrivalTurn)
      ..writeByte(2)
      ..write(obj.wavesRepelled)
      ..writeByte(3)
      ..write(obj.levelsLost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolcanoStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
