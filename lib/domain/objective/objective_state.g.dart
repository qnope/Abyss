// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objective_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObjectiveStateAdapter extends TypeAdapter<ObjectiveState> {
  @override
  final typeId = 54;

  @override
  ObjectiveState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ObjectiveState(
      completed: (fields[0] as List?)?.cast<ObjectiveId>(),
      tutorialEnabled: fields[1] == null ? false : fields[1] as bool,
      tipsEnabled: fields[2] == null ? false : fields[2] as bool,
      seenTips: (fields[3] as List?)?.cast<TipId>(),
    );
  }

  @override
  void write(BinaryWriter writer, ObjectiveState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.completed)
      ..writeByte(1)
      ..write(obj.tutorialEnabled)
      ..writeByte(2)
      ..write(obj.tipsEnabled)
      ..writeByte(3)
      ..write(obj.seenTips);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectiveStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
