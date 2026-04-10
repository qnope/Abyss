// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transition_base_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransitionBaseTypeAdapter extends TypeAdapter<TransitionBaseType> {
  @override
  final int typeId = 31;

  @override
  TransitionBaseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransitionBaseType.faille;
      case 1:
        return TransitionBaseType.cheminee;
      default:
        return TransitionBaseType.faille;
    }
  }

  @override
  void write(BinaryWriter writer, TransitionBaseType obj) {
    switch (obj) {
      case TransitionBaseType.faille:
        writer.writeByte(0);
        break;
      case TransitionBaseType.cheminee:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransitionBaseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
