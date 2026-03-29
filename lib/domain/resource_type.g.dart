// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResourceTypeAdapter extends TypeAdapter<ResourceType> {
  @override
  final int typeId = 2;

  @override
  ResourceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ResourceType.algae;
      case 1:
        return ResourceType.coral;
      case 2:
        return ResourceType.ore;
      case 3:
        return ResourceType.energy;
      case 4:
        return ResourceType.pearl;
      default:
        return ResourceType.algae;
    }
  }

  @override
  void write(BinaryWriter writer, ResourceType obj) {
    switch (obj) {
      case ResourceType.algae:
        writer.writeByte(0);
        break;
      case ResourceType.coral:
        writer.writeByte(1);
        break;
      case ResourceType.ore:
        writer.writeByte(2);
        break;
      case ResourceType.energy:
        writer.writeByte(3);
        break;
      case ResourceType.pearl:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
