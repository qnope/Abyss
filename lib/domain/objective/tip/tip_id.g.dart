// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_id.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipIdAdapter extends TypeAdapter<TipId> {
  @override
  final typeId = 55;

  @override
  TipId read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipId.noiseGauge;
      case 1:
        return TipId.worksites;
      case 2:
        return TipId.techChoice;
      case 3:
        return TipId.raidAnnounced;
      case 4:
        return TipId.raidReport;
      case 5:
        return TipId.lastChance;
      case 6:
        return TipId.lair;
      case 7:
        return TipId.monsterFamilies;
      case 8:
        return TipId.volcanoWave;
      case 9:
        return TipId.chestAndRuins;
      case 10:
        return TipId.transitionBase;
      case 11:
        return TipId.descent;
      case 12:
        return TipId.events;
      case 13:
        return TipId.warmCurrent;
      case 14:
        return TipId.wreck;
      case 15:
        return TipId.predators;
      case 16:
        return TipId.storm;
      case 17:
        return TipId.survivors;
      case 18:
        return TipId.caravan;
      case 19:
        return TipId.coldCurrent;
      default:
        return TipId.noiseGauge;
    }
  }

  @override
  void write(BinaryWriter writer, TipId obj) {
    switch (obj) {
      case TipId.noiseGauge:
        writer.writeByte(0);
      case TipId.worksites:
        writer.writeByte(1);
      case TipId.techChoice:
        writer.writeByte(2);
      case TipId.raidAnnounced:
        writer.writeByte(3);
      case TipId.raidReport:
        writer.writeByte(4);
      case TipId.lastChance:
        writer.writeByte(5);
      case TipId.lair:
        writer.writeByte(6);
      case TipId.monsterFamilies:
        writer.writeByte(7);
      case TipId.volcanoWave:
        writer.writeByte(8);
      case TipId.chestAndRuins:
        writer.writeByte(9);
      case TipId.transitionBase:
        writer.writeByte(10);
      case TipId.descent:
        writer.writeByte(11);
      case TipId.events:
        writer.writeByte(12);
      case TipId.warmCurrent:
        writer.writeByte(13);
      case TipId.wreck:
        writer.writeByte(14);
      case TipId.predators:
        writer.writeByte(15);
      case TipId.storm:
        writer.writeByte(16);
      case TipId.survivors:
        writer.writeByte(17);
      case TipId.caravan:
        writer.writeByte(18);
      case TipId.coldCurrent:
        writer.writeByte(19);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
