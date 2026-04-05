// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 1;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      player: fields[0] as Player,
      turn: fields[1] as int,
      createdAt: fields[2] as DateTime?,
      resources: (fields[3] as Map?)?.cast<ResourceType, Resource>(),
      buildings: (fields[4] as Map?)?.cast<BuildingType, Building>(),
      techBranches: (fields[5] as Map?)?.cast<TechBranch, TechBranchState>(),
      units: (fields[6] as Map?)?.cast<UnitType, Unit>(),
      recruitedUnitTypes: (fields[7] as List?)?.cast<UnitType>(),
      gameMap: fields[8] as GameMap?,
      pendingExplorations: (fields[9] as List?)?.cast<ExplorationOrder>(),
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.player)
      ..writeByte(1)
      ..write(obj.turn)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.resources)
      ..writeByte(4)
      ..write(obj.buildings)
      ..writeByte(5)
      ..write(obj.techBranches)
      ..writeByte(6)
      ..write(obj.units)
      ..writeByte(7)
      ..write(obj.recruitedUnitTypes)
      ..writeByte(8)
      ..write(obj.gameMap)
      ..writeByte(9)
      ..write(obj.pendingExplorations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
