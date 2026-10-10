// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objective_id.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObjectiveIdAdapter extends TypeAdapter<ObjectiveId> {
  @override
  final typeId = 53;

  @override
  ObjectiveId read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ObjectiveId.hqLevel1;
      case 1:
        return ObjectiveId.algaeFarm;
      case 2:
        return ObjectiveId.mines;
      case 3:
        return ObjectiveId.solarPanel;
      case 4:
        return ObjectiveId.hqLevel2;
      case 5:
        return ObjectiveId.barracksAndScouts;
      case 6:
        return ObjectiveId.explore;
      case 7:
        return ObjectiveId.laboratoryAndResearch;
      case 8:
        return ObjectiveId.firstRaid;
      case 9:
        return ObjectiveId.takeLair;
      case 10:
        return ObjectiveId.hqLevel5;
      case 11:
        return ObjectiveId.coralCitadel;
      case 12:
        return ObjectiveId.takeFaille;
      case 13:
        return ObjectiveId.descentModule;
      case 14:
        return ObjectiveId.descendLevel2;
      case 15:
        return ObjectiveId.hqLevel8;
      case 16:
        return ObjectiveId.takeCheminee;
      case 17:
        return ObjectiveId.pressureCapsule;
      case 18:
        return ObjectiveId.descendLevel3;
      case 19:
        return ObjectiveId.hqLevel10;
      case 20:
        return ObjectiveId.takeKernel;
      case 21:
        return ObjectiveId.kernelLevel1;
      case 22:
        return ObjectiveId.kernelLevel5;
      case 23:
        return ObjectiveId.kernelLevel10;
      default:
        return ObjectiveId.hqLevel1;
    }
  }

  @override
  void write(BinaryWriter writer, ObjectiveId obj) {
    switch (obj) {
      case ObjectiveId.hqLevel1:
        writer.writeByte(0);
      case ObjectiveId.algaeFarm:
        writer.writeByte(1);
      case ObjectiveId.mines:
        writer.writeByte(2);
      case ObjectiveId.solarPanel:
        writer.writeByte(3);
      case ObjectiveId.hqLevel2:
        writer.writeByte(4);
      case ObjectiveId.barracksAndScouts:
        writer.writeByte(5);
      case ObjectiveId.explore:
        writer.writeByte(6);
      case ObjectiveId.laboratoryAndResearch:
        writer.writeByte(7);
      case ObjectiveId.firstRaid:
        writer.writeByte(8);
      case ObjectiveId.takeLair:
        writer.writeByte(9);
      case ObjectiveId.hqLevel5:
        writer.writeByte(10);
      case ObjectiveId.coralCitadel:
        writer.writeByte(11);
      case ObjectiveId.takeFaille:
        writer.writeByte(12);
      case ObjectiveId.descentModule:
        writer.writeByte(13);
      case ObjectiveId.descendLevel2:
        writer.writeByte(14);
      case ObjectiveId.hqLevel8:
        writer.writeByte(15);
      case ObjectiveId.takeCheminee:
        writer.writeByte(16);
      case ObjectiveId.pressureCapsule:
        writer.writeByte(17);
      case ObjectiveId.descendLevel3:
        writer.writeByte(18);
      case ObjectiveId.hqLevel10:
        writer.writeByte(19);
      case ObjectiveId.takeKernel:
        writer.writeByte(20);
      case ObjectiveId.kernelLevel1:
        writer.writeByte(21);
      case ObjectiveId.kernelLevel5:
        writer.writeByte(22);
      case ObjectiveId.kernelLevel10:
        writer.writeByte(23);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectiveIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
