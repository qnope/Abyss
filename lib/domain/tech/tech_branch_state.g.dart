// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tech_branch_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TechBranchStateAdapter extends TypeAdapter<TechBranchState> {
  @override
  final int typeId = 7;

  @override
  TechBranchState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TechBranchState(
      branch: fields[0] as TechBranch,
      unlocked: fields[1] as bool,
      researchLevel: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TechBranchState obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.branch)
      ..writeByte(1)
      ..write(obj.unlocked)
      ..writeByte(2)
      ..write(obj.researchLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TechBranchStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
