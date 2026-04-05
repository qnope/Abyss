// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tech_branch.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TechBranchAdapter extends TypeAdapter<TechBranch> {
  @override
  final int typeId = 6;

  @override
  TechBranch read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TechBranch.military;
      case 1:
        return TechBranch.resources;
      case 2:
        return TechBranch.explorer;
      default:
        return TechBranch.military;
    }
  }

  @override
  void write(BinaryWriter writer, TechBranch obj) {
    switch (obj) {
      case TechBranch.military:
        writer.writeByte(0);
        break;
      case TechBranch.resources:
        writer.writeByte(1);
        break;
      case TechBranch.explorer:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TechBranchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
