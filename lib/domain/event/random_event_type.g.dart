// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'random_event_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RandomEventTypeAdapter extends TypeAdapter<RandomEventType> {
  @override
  final typeId = 50;

  @override
  RandomEventType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RandomEventType.warmCurrent;
      case 1:
        return RandomEventType.wreck;
      case 2:
        return RandomEventType.predators;
      case 3:
        return RandomEventType.storm;
      case 4:
        return RandomEventType.survivors;
      case 5:
        return RandomEventType.caravan;
      case 6:
        return RandomEventType.coldCurrent;
      default:
        return RandomEventType.warmCurrent;
    }
  }

  @override
  void write(BinaryWriter writer, RandomEventType obj) {
    switch (obj) {
      case RandomEventType.warmCurrent:
        writer.writeByte(0);
      case RandomEventType.wreck:
        writer.writeByte(1);
      case RandomEventType.predators:
        writer.writeByte(2);
      case RandomEventType.storm:
        writer.writeByte(3);
      case RandomEventType.survivors:
        writer.writeByte(4);
      case RandomEventType.caravan:
        writer.writeByte(5);
      case RandomEventType.coldCurrent:
        writer.writeByte(6);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RandomEventTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
