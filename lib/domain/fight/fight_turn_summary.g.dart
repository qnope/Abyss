// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fight_turn_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FightTurnSummaryAdapter extends TypeAdapter<FightTurnSummary> {
  @override
  final typeId = 28;

  @override
  FightTurnSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FightTurnSummary(
      turnNumber: (fields[0] as num).toInt(),
      attacksPlayed: (fields[1] as num).toInt(),
      critCount: (fields[2] as num).toInt(),
      damageDealtByPlayer: (fields[3] as num).toInt(),
      damageDealtByMonster: (fields[4] as num).toInt(),
      playerAliveAtEnd: (fields[5] as num).toInt(),
      monsterAliveAtEnd: (fields[6] as num).toInt(),
      playerHpAtEnd: (fields[7] as num).toInt(),
      monsterHpAtEnd: (fields[8] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, FightTurnSummary obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.turnNumber)
      ..writeByte(1)
      ..write(obj.attacksPlayed)
      ..writeByte(2)
      ..write(obj.critCount)
      ..writeByte(3)
      ..write(obj.damageDealtByPlayer)
      ..writeByte(4)
      ..write(obj.damageDealtByMonster)
      ..writeByte(5)
      ..write(obj.playerAliveAtEnd)
      ..writeByte(6)
      ..write(obj.monsterAliveAtEnd)
      ..writeByte(7)
      ..write(obj.playerHpAtEnd)
      ..writeByte(8)
      ..write(obj.monsterHpAtEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FightTurnSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
