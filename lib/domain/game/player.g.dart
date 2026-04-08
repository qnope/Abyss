// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      name: fields[0] as String,
      id: fields[1] as String?,
      baseX: fields[2] as int,
      baseY: fields[3] as int,
      resources: (fields[4] as Map?)?.cast<ResourceType, Resource>(),
      buildings: (fields[5] as Map?)?.cast<BuildingType, Building>(),
      techBranches: (fields[6] as Map?)?.cast<TechBranch, TechBranchState>(),
      units: (fields[7] as Map?)?.cast<UnitType, Unit>(),
      recruitedUnitTypes: (fields[8] as List?)?.cast<UnitType>(),
      pendingExplorations: (fields[9] as List?)?.cast<ExplorationOrder>(),
      revealedCellsList: (fields[10] as List?)?.cast<GridPosition>(),
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.units)
      ..writeByte(8)
      ..write(obj.recruitedUnitTypes)
      ..writeByte(9)
      ..write(obj.pendingExplorations)
      ..writeByte(10)
      ..write(obj.revealedCellsList);
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
