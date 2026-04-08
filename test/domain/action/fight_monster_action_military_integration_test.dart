import 'dart:math';

import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fight_monster_action_helper.dart';

/// End-to-end integration tests for the military tech branch.
///
/// Two identical scenarios are run with the same RNG seed and the same
/// selected units; the only difference is the player's military research
/// level. The boosted run must deal strictly more damage than the baseline,
/// proving the bonus flows through action -> builder -> engine.
void main() {
  FightMonsterResult runFight({required int level, required int seed}) {
    final scenario = createFightScenario(
      difficulty: MonsterDifficulty.hard,
      unitCount: 4,
      stock: {UnitType.harpoonist: 6},
      militaryResearchLevel: level,
    );
    final action = FightMonsterAction(
      targetX: 1,
      targetY: 1,
      selectedUnits: {UnitType.harpoonist: 6},
      random: Random(seed),
    );
    return action.execute(scenario.game, scenario.player)
        as FightMonsterResult;
  }

  int totalDamageOnMonsters(FightMonsterResult r) =>
      r.fight!.turnSummaries.fold<int>(
        0,
        (acc, t) => acc + t.damageDealtByPlayer,
      );

  group('FightMonsterAction military integration', () {
    // Seed 7 picked for deterministic reproducibility. Hard-difficulty
    // lair (4 lvl-3 monsters, 140 total HP) vs 6 harpoonists keeps the
    // baseline run long enough that the level-3 atk bonus produces a
    // clearly larger accumulated damage total (no overkill clamp).
    const int seed = 7;

    test('military level 3 deals more damage than level 0', () {
      final FightMonsterResult r0 = runFight(level: 0, seed: seed);
      final FightMonsterResult r3 = runFight(level: 3, seed: seed);

      expect(
        totalDamageOnMonsters(r3),
        greaterThan(totalDamageOnMonsters(r0)),
      );
    });

    test('military level 3 produces a victory at least as often', () {
      final FightMonsterResult r0 = runFight(level: 0, seed: seed);
      final FightMonsterResult r3 = runFight(level: 3, seed: seed);

      // The boosted side must never lose a fight that the baseline wins.
      expect(r0.victory && !r3.victory, isFalse);
    });

    test('bonus also visible on initialPlayerCombatants atk', () {
      final FightMonsterResult r0 = runFight(level: 0, seed: seed);
      final FightMonsterResult r3 = runFight(level: 3, seed: seed);

      expect(
        r3.fight!.initialPlayerCombatants.first.atk,
        greaterThan(r0.fight!.initialPlayerCombatants.first.atk),
      );
    });
  });
}
