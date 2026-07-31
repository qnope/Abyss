// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingTypeAdapter extends TypeAdapter<BuildingType> {
  @override
  final typeId = 4;

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
      case 7:
        return BuildingType.coralCitadel;
      case 8:
        return BuildingType.descentModule;
      case 9:
        return BuildingType.pressureCapsule;
      case 10:
        return BuildingType.volcanicKernel;
      default:
        return BuildingType.headquarters;
    }
  }

  @override
  void write(BinaryWriter writer, BuildingType obj) {
    switch (obj) {
      case BuildingType.headquarters:
        writer.writeByte(0);
      case BuildingType.algaeFarm:
        writer.writeByte(1);
      case BuildingType.coralMine:
        writer.writeByte(2);
      case BuildingType.oreExtractor:
        writer.writeByte(3);
      case BuildingType.solarPanel:
        writer.writeByte(4);
      case BuildingType.laboratory:
        writer.writeByte(5);
      case BuildingType.barracks:
        writer.writeByte(6);
      case BuildingType.coralCitadel:
        writer.writeByte(7);
      case BuildingType.descentModule:
        writer.writeByte(8);
      case BuildingType.pressureCapsule:
        writer.writeByte(9);
      case BuildingType.volcanicKernel:
        writer.writeByte(10);
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
