// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventStateAdapter extends TypeAdapter<EventState> {
  @override
  final typeId = 51;

  @override
  EventState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventState(
      nextDrawTurn: (fields[0] as num?)?.toInt(),
      pending: fields[1] as RandomEventType?,
      pendingTurn: (fields[2] as num?)?.toInt(),
      lastDrawn: fields[3] as RandomEventType?,
      active: fields[4] as RandomEventType?,
      activeUntilTurn: (fields[5] as num?)?.toInt(),
      heating: fields[6] == null ? false : fields[6] as bool,
      eventsSeen: fields[7] == null ? 0 : (fields[7] as num).toInt(),
      survivors: (fields[8] as num?)?.toInt(),
      tradeFrom: fields[9] as ResourceType?,
      tradeTo: fields[10] as ResourceType?,
      predatorWave: fields[11] as MonsterLair?,
      predatorsTurn: (fields[12] as num?)?.toInt(),
      wreckPosition: fields[13] as GridPosition?,
      wreckUntilTurn: (fields[14] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, EventState obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.nextDrawTurn)
      ..writeByte(1)
      ..write(obj.pending)
      ..writeByte(2)
      ..write(obj.pendingTurn)
      ..writeByte(3)
      ..write(obj.lastDrawn)
      ..writeByte(4)
      ..write(obj.active)
      ..writeByte(5)
      ..write(obj.activeUntilTurn)
      ..writeByte(6)
      ..write(obj.heating)
      ..writeByte(7)
      ..write(obj.eventsSeen)
      ..writeByte(8)
      ..write(obj.survivors)
      ..writeByte(9)
      ..write(obj.tradeFrom)
      ..writeByte(10)
      ..write(obj.tradeTo)
      ..writeByte(11)
      ..write(obj.predatorWave)
      ..writeByte(12)
      ..write(obj.predatorsTurn)
      ..writeByte(13)
      ..write(obj.wreckPosition)
      ..writeByte(14)
      ..write(obj.wreckUntilTurn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
