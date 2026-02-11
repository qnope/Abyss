import 'resource.dart';

enum CombatResult { attackerVictory, defenderVictory, draw }

enum CombatType { attack, raid, reconnaissance, support, interception }

class CombatReport {
  final int id;
  final int attackerId;
  final int defenderId;
  final DateTime timestamp;
  final CombatType combatType;
  final CombatResult result;
  final Map<String, int> attackerLosses;
  final Map<String, int> defenderLosses;
  final Resources? spoils;
  final int rounds;
  final List<String> battleLog;

  const CombatReport({
    required this.id,
    required this.attackerId,
    required this.defenderId,
    required this.timestamp,
    required this.combatType,
    required this.result,
    this.attackerLosses = const {},
    this.defenderLosses = const {},
    this.spoils,
    required this.rounds,
    this.battleLog = const [],
  });

  CombatReport copyWith({
    int? id,
    int? attackerId,
    int? defenderId,
    DateTime? timestamp,
    CombatType? combatType,
    CombatResult? result,
    Map<String, int>? attackerLosses,
    Map<String, int>? defenderLosses,
    Resources? spoils,
    int? rounds,
    List<String>? battleLog,
  }) =>
      CombatReport(
        id: id ?? this.id,
        attackerId: attackerId ?? this.attackerId,
        defenderId: defenderId ?? this.defenderId,
        timestamp: timestamp ?? this.timestamp,
        combatType: combatType ?? this.combatType,
        result: result ?? this.result,
        attackerLosses: attackerLosses ?? this.attackerLosses,
        defenderLosses: defenderLosses ?? this.defenderLosses,
        spoils: spoils ?? this.spoils,
        rounds: rounds ?? this.rounds,
        battleLog: battleLog ?? this.battleLog,
      );
}
