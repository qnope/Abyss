// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_journal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReplayJournalAdapter extends TypeAdapter<ReplayJournal> {
  @override
  final typeId = 45;

  @override
  ReplayJournal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReplayJournal(
      mapSeed: (fields[0] as num).toInt(),
      playerName: fields[1] as String,
      actions: (fields[2] as Map?)?.map(
        (dynamic k, dynamic v) =>
            MapEntry((k as num).toInt(), (v as List).cast<String>()),
      ),
      endTurnSeeds: (fields[3] as Map?)?.cast<int, int>(),
      exact: fields[4] == null ? true : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReplayJournal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.mapSeed)
      ..writeByte(1)
      ..write(obj.playerName)
      ..writeByte(2)
      ..write(obj.actions)
      ..writeByte(3)
      ..write(obj.endTurnSeeds)
      ..writeByte(4)
      ..write(obj.exact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplayJournalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
