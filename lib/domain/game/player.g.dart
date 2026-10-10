// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
        name: fields[0] as String,
        id: fields[1] as String?,
        baseX: fields[2] == null ? 0 : (fields[2] as num).toInt(),
        baseY: fields[3] == null ? 0 : (fields[3] as num).toInt(),
        resources: (fields[4] as Map?)?.cast<ResourceType, Resource>(),
        buildings: (fields[5] as Map?)?.cast<BuildingType, Building>(),
        techBranches: (fields[6] as Map?)?.cast<TechBranch, TechBranchState>(),
        unitsPerLevel: (fields[7] as Map?)?.map(
          (dynamic k, dynamic v) =>
              MapEntry((k as num).toInt(), (v as Map).cast<UnitType, Unit>()),
        ),
        recruitedUnitTypes: (fields[8] as List?)?.cast<UnitType>(),
        pendingExplorations: (fields[9] as List?)?.cast<ExplorationOrder>(),
        revealedCellsPerLevel: (fields[10] as Map?)?.map(
          (dynamic k, dynamic v) =>
              MapEntry((k as num).toInt(), (v as List).cast<GridPosition>()),
        ),
        historyEntries: (fields[11] as List?)?.cast<HistoryEntry>(),
        pendingReinforcements:
            (fields[13] as List?)?.cast<ReinforcementOrder>(),
        raidState: fields[14] as RaidState?,
        volcanoState: fields[16] as VolcanoState?,
        eventState: fields[17] as EventState?,
        worksite: fields[15] as Worksite?,
      )
      ..savedObjectiveState = fields[18] as ObjectiveState?
      ..savedFallen = fields[19] as bool?;
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.baseX)
      ..writeByte(3)
      ..write(obj.baseY)
      ..writeByte(4)
      ..write(obj.resources)
      ..writeByte(5)
      ..write(obj.buildings)
      ..writeByte(6)
      ..write(obj.techBranches)
      ..writeByte(7)
      ..write(obj.unitsPerLevel)
      ..writeByte(8)
      ..write(obj.recruitedUnitTypes)
      ..writeByte(9)
      ..write(obj.pendingExplorations)
      ..writeByte(10)
      ..write(obj.revealedCellsPerLevel)
      ..writeByte(11)
      ..write(obj.historyEntries)
      ..writeByte(13)
      ..write(obj.pendingReinforcements)
      ..writeByte(14)
      ..write(obj.raidState)
      ..writeByte(15)
      ..write(obj.worksite)
      ..writeByte(16)
      ..write(obj.volcanoState)
      ..writeByte(17)
      ..write(obj.eventState)
      ..writeByte(18)
      ..write(obj.savedObjectiveState)
      ..writeByte(19)
      ..write(obj.savedFallen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
