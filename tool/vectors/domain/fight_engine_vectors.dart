import 'dart:math';

import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_engine.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';

import '../vector_file.dart';
import 'fight_scenarios.dart';
import 'vector_inputs.dart';

/// Whole fights, turn by turn: who wins, in how many turns, with which
/// crits and which hit points left on every combatant.
abstract final class FightEngineVectors {
  /// The dice of each fight: small, common and the largest of the game.
  static const List<int> seeds = <int>[1, 42, 2147483646];

  static const String _sides =
      'each side lists runs [typeKey, side, maxHp, atk, def, isBoss, '
      'count], count Combatant(...) each, in order';

  static const String _out =
      'out: winner, turnCount, initialMonsterCount, finalMonsterCount, '
      'the currentHp of every combatant of each side in order, and turns: '
      'per FightTurnSummary [attacksPlayed, critCount, damageDealtByPlayer, '
      'damageDealtByMonster, playerAliveAtEnd, monsterAliveAtEnd, '
      'playerHpAtEnd, monsterHpAtEnd]';

  static final VectorFile file = VectorFile('fight_engine', {
    'resolve': VectorSection(
      'FightEngine(random: Random(seed)).resolve(playerSide: players, '
          'monsterSide: monsters); $_sides. $_out',
      () => [
        for (final e in FightScenarios.all.entries)
          for (final int seed in seeds)
            {
              'fight': e.key,
              'seed': seed,
              'players': VectorInputs.runs(e.value.$1()),
              'monsters': VectorInputs.runs(e.value.$2()),
              'out': resolve(e.value.$1(), e.value.$2(), Random(seed)),
            },
      ],
    ),
    'critChance': VectorSection(
      'FightEngine(random: Random(seed), critChance: critChance)'
          '.resolve(...) as in resolve',
      () => [
        for (final String fight in const ['duel', 'generic medium', 'faille'])
          for (final double chance in const <double>[0, 0.5, 1])
            {
              'fight': fight,
              'seed': 7,
              'critChance': chance,
              'players': VectorInputs.runs(FightScenarios.all[fight]!.$1()),
              'monsters': VectorInputs.runs(FightScenarios.all[fight]!.$2()),
              'out': resolve(
                FightScenarios.all[fight]!.$1(),
                FightScenarios.all[fight]!.$2(),
                Random(7),
                critChance: chance,
              ),
            },
      ],
    ),
    'twoFights': VectorSection(
      'Two fights in a row on the same Random(seed), a new FightEngine '
          'for each, as a rehearsal plays them: out lists both results',
      () => [
        for (final String fight in const ['generic easy', 'faille'])
          for (final int seed in seeds)
            {
              'fight': fight,
              'seed': seed,
              'players': VectorInputs.runs(FightScenarios.all[fight]!.$1()),
              'monsters': VectorInputs.runs(FightScenarios.all[fight]!.$2()),
              'out': _twice(FightScenarios.all[fight]!, Random(seed)),
            },
      ],
    ),
  });

  /// The fight of [players] against [monsters] with [random], as a case
  /// writes its result.
  static Map<String, Object?> resolve(
    List<Combatant> players,
    List<Combatant> monsters,
    Random random, {
    double critChance = 0.05,
  }) {
    final FightResult result = FightEngine(
      random: random,
      critChance: critChance,
    ).resolve(playerSide: players, monsterSide: monsters);
    return {
      'winner': result.winner,
      'turnCount': result.turnCount,
      'initialMonsterCount': result.initialMonsterCount,
      'finalMonsterCount': result.finalMonsterCount,
      'playerHp': [for (final c in result.finalPlayerCombatants) c.currentHp],
      'monsterHp': [for (final c in monsters) c.currentHp],
      'turns': [for (final t in result.turnSummaries) _turn(t)],
    };
  }

  static List<int> _turn(FightTurnSummary t) => [
    t.attacksPlayed, t.critCount, t.damageDealtByPlayer,
    t.damageDealtByMonster, t.playerAliveAtEnd, t.monsterAliveAtEnd,
    t.playerHpAtEnd, t.monsterHpAtEnd,
  ];

  static List<Object?> _twice(
    (List<Combatant> Function(), List<Combatant> Function()) fight,
    Random random,
  ) => [
    resolve(fight.$1(), fight.$2(), random),
    resolve(fight.$1(), fight.$2(), random),
  ];
}
