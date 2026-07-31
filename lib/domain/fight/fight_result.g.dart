// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fight_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FightResultAdapter extends TypeAdapter<FightResult> {
  @override
  final typeId = 29;

  @override
  FightResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FightResult(
      winner: fields[0] as CombatSide,
      turnCount: (fields[1] as num).toInt(),
      turnSummaries: (fields[2] as List).cast<FightTurnSummary>(),
      initialPlayerCombatants: (fields[3] as List).cast<Combatant>(),
      finalPlayerCombatants: (fields[4] as List).cast<Combatant>(),
      initialMonsterCount: (fields[5] as num).toInt(),
      finalMonsterCount: (fields[6] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, FightResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.winner)
      ..writeByte(1)
      ..write(obj.turnCount)
      ..writeByte(2)
      ..write(obj.turnSummaries)
      ..writeByte(3)
      ..write(obj.initialPlayerCombatants)
      ..writeByte(4)
      ..write(obj.finalPlayerCombatants)
      ..writeByte(5)
      ..write(obj.initialMonsterCount)
      ..writeByte(6)
      ..write(obj.finalMonsterCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FightResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
