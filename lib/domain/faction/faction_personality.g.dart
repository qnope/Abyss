// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faction_personality.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FactionPersonalityAdapter extends TypeAdapter<FactionPersonality> {
  @override
  final typeId = 56;

  @override
  FactionPersonality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FactionPersonality.wreckPillagers;
      case 1:
        return FactionPersonality.pearlOrder;
      case 2:
        return FactionPersonality.anglerCult;
      case 3:
        return FactionPersonality.murenaHorde;
      case 4:
        return FactionPersonality.siphonophoreGuild;
      case 5:
        return FactionPersonality.silenceMonks;
      case 6:
        return FactionPersonality.currentNomads;
      case 7:
        return FactionPersonality.pyrosomeHive;
      case 8:
        return FactionPersonality.magmaSmiths;
      case 9:
        return FactionPersonality.krakenFaithful;
      default:
        return FactionPersonality.wreckPillagers;
    }
  }

  @override
  void write(BinaryWriter writer, FactionPersonality obj) {
    switch (obj) {
      case FactionPersonality.wreckPillagers:
        writer.writeByte(0);
      case FactionPersonality.pearlOrder:
        writer.writeByte(1);
      case FactionPersonality.anglerCult:
        writer.writeByte(2);
      case FactionPersonality.murenaHorde:
        writer.writeByte(3);
      case FactionPersonality.siphonophoreGuild:
        writer.writeByte(4);
      case FactionPersonality.silenceMonks:
        writer.writeByte(5);
      case FactionPersonality.currentNomads:
        writer.writeByte(6);
      case FactionPersonality.pyrosomeHive:
        writer.writeByte(7);
      case FactionPersonality.magmaSmiths:
        writer.writeByte(8);
      case FactionPersonality.krakenFaithful:
        writer.writeByte(9);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactionPersonalityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
