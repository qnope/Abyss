// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingEntryAdapter extends TypeAdapter<BuildingEntry> {
  @override
  final int typeId = 19;

  @override
  BuildingEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingEntry(
      turn: fields[0] as int,
      buildingType: fields[4] as BuildingType,
      newLevel: fields[5] as int,
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BuildingEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.buildingType)
      ..writeByte(5)
      ..write(obj.newLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CollectEntryAdapter extends TypeAdapter<CollectEntry> {
  @override
  final int typeId = 23;

  @override
  CollectEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectEntry(
      turn: fields[0] as int,
      targetX: fields[4] as int,
      targetY: fields[5] as int,
      gains: (fields[6] as Map).cast<ResourceType, int>(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CollectEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.targetX)
      ..writeByte(5)
      ..write(obj.targetY)
      ..writeByte(6)
      ..write(obj.gains);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CombatEntryAdapter extends TypeAdapter<CombatEntry> {
  @override
  final int typeId = 24;

  @override
  CombatEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CombatEntry(
      turn: fields[0] as int,
      victory: fields[4] as bool,
      targetX: fields[5] as int,
      targetY: fields[6] as int,
      lair: fields[7] as MonsterLair,
      fightResult: fields[8] as FightResult,
      loot: (fields[9] as Map).cast<ResourceType, int>(),
      sent: (fields[10] as Map).cast<UnitType, int>(),
      survivorsIntact: (fields[11] as Map).cast<UnitType, int>(),
      wounded: (fields[12] as Map).cast<UnitType, int>(),
      dead: (fields[13] as Map).cast<UnitType, int>(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CombatEntry obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.victory)
      ..writeByte(5)
      ..write(obj.targetX)
      ..writeByte(6)
      ..write(obj.targetY)
      ..writeByte(7)
      ..write(obj.lair)
      ..writeByte(8)
      ..write(obj.fightResult)
      ..writeByte(9)
      ..write(obj.loot)
      ..writeByte(10)
      ..write(obj.sent)
      ..writeByte(11)
      ..write(obj.survivorsIntact)
      ..writeByte(12)
      ..write(obj.wounded)
      ..writeByte(13)
      ..write(obj.dead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombatEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExploreEntryAdapter extends TypeAdapter<ExploreEntry> {
  @override
  final int typeId = 22;

  @override
  ExploreEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExploreEntry(
      turn: fields[0] as int,
      targetX: fields[4] as int,
      targetY: fields[5] as int,
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExploreEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.targetX)
      ..writeByte(5)
      ..write(obj.targetY);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExploreEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecruitEntryAdapter extends TypeAdapter<RecruitEntry> {
  @override
  final int typeId = 21;

  @override
  RecruitEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecruitEntry(
      turn: fields[0] as int,
      unitType: fields[4] as UnitType,
      quantity: fields[5] as int,
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecruitEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.unitType)
      ..writeByte(5)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecruitEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResearchEntryAdapter extends TypeAdapter<ResearchEntry> {
  @override
  final int typeId = 20;

  @override
  ResearchEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResearchEntry(
      turn: fields[0] as int,
      branch: fields[4] as TechBranch,
      isUnlock: fields[5] as bool,
      newLevel: fields[6] as int?,
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ResearchEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.branch)
      ..writeByte(5)
      ..write(obj.isUnlock)
      ..writeByte(6)
      ..write(obj.newLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResearchEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TurnEndEntryAdapter extends TypeAdapter<TurnEndEntry> {
  @override
  final int typeId = 25;

  @override
  TurnEndEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TurnEndEntry(
      turn: fields[0] as int,
      changes: (fields[4] as List).cast<TurnResourceChange>(),
      deactivatedBuildings: (fields[5] as List).cast<BuildingType>(),
      lostUnits: (fields[6] as Map).cast<UnitType, int>(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TurnEndEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.changes)
      ..writeByte(5)
      ..write(obj.deactivatedBuildings)
      ..writeByte(6)
      ..write(obj.lostUnits);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurnEndEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CaptureEntryAdapter extends TypeAdapter<CaptureEntry> {
  @override
  final int typeId = 34;

  @override
  CaptureEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaptureEntry(
      turn: fields[0] as int,
      transitionBaseName: fields[4] as String,
      fightResult: fields[5] as FightResult,
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CaptureEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.transitionBaseName)
      ..writeByte(5)
      ..write(obj.fightResult);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DescentEntryAdapter extends TypeAdapter<DescentEntry> {
  @override
  final int typeId = 35;

  @override
  DescentEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DescentEntry(
      turn: fields[0] as int,
      targetLevel: fields[4] as int,
      unitCount: fields[5] as int,
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DescentEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.targetLevel)
      ..writeByte(5)
      ..write(obj.unitCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DescentEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReinforcementEntryAdapter extends TypeAdapter<ReinforcementEntry> {
  @override
  final int typeId = 36;

  @override
  ReinforcementEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReinforcementEntry(
      turn: fields[0] as int,
      targetLevel: fields[4] as int,
      unitCount: fields[5] as int,
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReinforcementEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.targetLevel)
      ..writeByte(5)
      ..write(obj.unitCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReinforcementEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
