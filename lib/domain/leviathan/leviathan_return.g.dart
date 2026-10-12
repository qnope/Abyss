// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leviathan_return.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeviathanReturnAdapter extends TypeAdapter<LeviathanReturn> {
  @override
  final typeId = 60;

  @override
  LeviathanReturn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeviathanReturn(
      postName: fields[0] as String?,
      level: (fields[1] as num?)?.toInt(),
      at: fields[2] as GridPosition?,
      strikeTurn: (fields[3] as num?)?.toInt(),
      over: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LeviathanReturn obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.postName)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.at)
      ..writeByte(3)
      ..write(obj.strikeTurn)
      ..writeByte(4)
      ..write(obj.over);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeviathanReturnAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
