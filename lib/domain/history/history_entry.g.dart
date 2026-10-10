// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingEntryAdapter extends TypeAdapter<BuildingEntry> {
  @override
  final typeId = 19;

  @override
  BuildingEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingEntry(
      turn: (fields[0] as num).toInt(),
      buildingType: fields[4] as BuildingType,
      newLevel: (fields[5] as num).toInt(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BuildingEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 23;

  @override
  CollectEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectEntry(
      turn: (fields[0] as num).toInt(),
      targetX: (fields[4] as num).toInt(),
      targetY: (fields[5] as num).toInt(),
      gains: (fields[6] as Map).cast<ResourceType, int>(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CollectEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 24;

  @override
  CombatEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CombatEntry(
      turn: (fields[0] as num).toInt(),
      victory: fields[4] as bool,
      targetX: (fields[5] as num).toInt(),
      targetY: (fields[6] as num).toInt(),
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
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 22;

  @override
  ExploreEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExploreEntry(
      turn: (fields[0] as num).toInt(),
      targetX: (fields[4] as num).toInt(),
      targetY: (fields[5] as num).toInt(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExploreEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 21;

  @override
  RecruitEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecruitEntry(
      turn: (fields[0] as num).toInt(),
      unitType: fields[4] as UnitType,
      quantity: (fields[5] as num).toInt(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecruitEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 20;

  @override
  ResearchEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResearchEntry(
      turn: (fields[0] as num).toInt(),
      branch: fields[4] as TechBranch,
      isUnlock: fields[5] as bool,
      newLevel: (fields[6] as num?)?.toInt(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ResearchEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 25;

  @override
  TurnEndEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TurnEndEntry(
      turn: (fields[0] as num).toInt(),
      changes: (fields[4] as List).cast<TurnResourceChange>(),
      deactivatedBuildings: (fields[5] as List).cast<BuildingType>(),
      lostUnits: (fields[6] as Map).cast<UnitType, int>(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TurnEndEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 34;

  @override
  CaptureEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaptureEntry(
      turn: (fields[0] as num).toInt(),
      transitionBaseName: fields[4] as String,
      fightResult: fields[5] as FightResult,
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CaptureEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 35;

  @override
  DescentEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DescentEntry(
      turn: (fields[0] as num).toInt(),
      targetLevel: (fields[4] as num).toInt(),
      unitCount: (fields[5] as num).toInt(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DescentEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.turn)
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
  final typeId = 36;

  @override
  ReinforcementEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReinforcementEntry(
      turn: (fields[0] as num).toInt(),
      targetLevel: (fields[4] as num).toInt(),
      unitCount: (fields[5] as num).toInt(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReinforcementEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.turn)
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

class RaidEntryAdapter extends TypeAdapter<RaidEntry> {
  @override
  final typeId = 39;

  @override
  RaidEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RaidEntry(
      turn: (fields[0] as num).toInt(),
      victory: fields[4] as bool,
      wave: fields[5] as MonsterLair,
      fightResult: fields[6] as FightResult,
      loot: (fields[7] as Map).cast<ResourceType, int>(),
      pillaged: (fields[8] as Map).cast<ResourceType, int>(),
      defenders: (fields[9] as Map).cast<UnitType, int>(),
      survivorsIntact: (fields[10] as Map).cast<UnitType, int>(),
      wounded: (fields[11] as Map).cast<UnitType, int>(),
      dead: (fields[12] as Map).cast<UnitType, int>(),
      rampartLevel: (fields[13] as num).toInt(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RaidEntry obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.victory)
      ..writeByte(5)
      ..write(obj.wave)
      ..writeByte(6)
      ..write(obj.fightResult)
      ..writeByte(7)
      ..write(obj.loot)
      ..writeByte(8)
      ..write(obj.pillaged)
      ..writeByte(9)
      ..write(obj.defenders)
      ..writeByte(10)
      ..write(obj.survivorsIntact)
      ..writeByte(11)
      ..write(obj.wounded)
      ..writeByte(12)
      ..write(obj.dead)
      ..writeByte(13)
      ..write(obj.rampartLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaidEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VolcanoEntryAdapter extends TypeAdapter<VolcanoEntry> {
  @override
  final typeId = 48;

  @override
  VolcanoEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VolcanoEntry(
      turn: (fields[0] as num).toInt(),
      victory: fields[4] as bool,
      wave: fields[5] as MonsterLair,
      fightResult: fields[6] as FightResult,
      kernelLevel: (fields[7] as num).toInt(),
      defenders: (fields[8] as Map).cast<UnitType, int>(),
      survivorsIntact: (fields[9] as Map).cast<UnitType, int>(),
      wounded: (fields[10] as Map).cast<UnitType, int>(),
      dead: (fields[11] as Map).cast<UnitType, int>(),
      subtitle: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VolcanoEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.victory)
      ..writeByte(5)
      ..write(obj.wave)
      ..writeByte(6)
      ..write(obj.fightResult)
      ..writeByte(7)
      ..write(obj.kernelLevel)
      ..writeByte(8)
      ..write(obj.defenders)
      ..writeByte(9)
      ..write(obj.survivorsIntact)
      ..writeByte(10)
      ..write(obj.wounded)
      ..writeByte(11)
      ..write(obj.dead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolcanoEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventEntryAdapter extends TypeAdapter<EventEntry> {
  @override
  final typeId = 52;

  @override
  EventEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventEntry(
      turn: (fields[0] as num).toInt(),
      type: fields[4] as RandomEventType,
      accepted: fields[5] as bool,
      defaulted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EventEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.turn)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.accepted)
      ..writeByte(6)
      ..write(obj.defaulted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
