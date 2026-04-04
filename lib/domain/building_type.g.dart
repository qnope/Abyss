// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingTypeAdapter extends TypeAdapter<BuildingType> {
  @override
  final int typeId = 4;

  @override
  BuildingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuildingType.headquarters;
      case 1:
        return BuildingType.algaeFarm;
      case 2:
        return BuildingType.coralMine;
      case 3:
        return BuildingType.oreExtractor;
      case 4:
        return BuildingType.solarPanel;
      case 5:
        return BuildingType.laboratory;
      case 6:
        return BuildingType.barracks;
      default:
        return BuildingType.headquarters;
    }
  }

  @override
  void write(BinaryWriter writer, BuildingType obj) {
    switch (obj) {
      case BuildingType.headquarters:
        writer.writeByte(0);
        break;
      case BuildingType.algaeFarm:
        writer.writeByte(1);
        break;
      case BuildingType.coralMine:
        writer.writeByte(2);
        break;
      case BuildingType.oreExtractor:
        writer.writeByte(3);
        break;
      case BuildingType.solarPanel:
        writer.writeByte(4);
        break;
      case BuildingType.laboratory:
        writer.writeByte(5);
        break;
      case BuildingType.barracks:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
