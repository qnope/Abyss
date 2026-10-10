import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_defence_advisor.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'raid_test_helper.dart';

/// A first raid of Normal where the Nuée dominates.
const _wave = MonsterLair(
  difficulty: MonsterDifficulty.easy,
  family: MonsterFamily.swarm,
  unitCount: 22,
  secondFamily: MonsterFamily.armoured,
  secondCount: 6,
);

int _needed({Map<UnitType, int> units = const {}, int citadel = 0}) =>
    RaidDefenceAdvisor.harpoonistsFor(
      raidPlayer(units: units, citadelLevel: citadel),
      _wave,
    )!;

void main() {
  test('the advised harpoonists win at least 95 % of the rehearsals', () {
    final int needed = _needed();
    const planner = RaidDefenceAdvisor.planner;
    List<Combatant> wave() => CombatantBuilder.monsterCombatantsFrom(_wave);

    expect(planner.rehearsals, 20);
    expect(planner.confidence, 0.95);
    expect(planner.wins({UnitType.harpoonist: needed}, wave), isTrue);
    expect(planner.wins({UnitType.harpoonist: needed - 1}, wave), isFalse);
  });

  test('counts the harpoonists already on the base', () {
    final int needed = _needed();

    expect(_needed(units: {UnitType.harpoonist: 3}), needed);
    expect(_needed(units: {UnitType.harpoonist: needed + 4}), needed + 4);
  });

  test('a bigger wave needs more harpoonists', () {
    final player = raidPlayer();
    int neededAgainst(int count) => RaidDefenceAdvisor.harpoonistsFor(
          player,
          MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: count),
        )!;

    expect(neededAgainst(30), greaterThan(neededAgainst(10)));
  });

  test('the Citadel rampart and the other defenders lower the count', () {
    final int alone = _needed();

    expect(_needed(citadel: 5), lessThan(alone));
    expect(_needed(units: {UnitType.guardian: 6}), lessThan(alone));
  });

  test('is the same for the same game and leaves the player as it is', () {
    final player = raidPlayer(units: {UnitType.scout: 2});
    final int first = RaidDefenceAdvisor.harpoonistsFor(player, _wave)!;

    expect(RaidDefenceAdvisor.harpoonistsFor(player, _wave), first);
    expect(unitsOnBase(player), 2);
  });

  test('follows the base as it changes, from one call to the next', () {
    final player = raidPlayer();
    final int needed = RaidDefenceAdvisor.harpoonistsFor(player, _wave)!;

    player.unitsOnLevel(1)[UnitType.harpoonist]!.count = needed + 2;

    expect(RaidDefenceAdvisor.harpoonistsFor(player, _wave), needed + 2);
  });

  test('none when no number of harpoonists is enough', () {
    const horde = MonsterLair(
        difficulty: MonsterDifficulty.hard, unitCount: 400);

    expect(RaidDefenceAdvisor.harpoonistsFor(raidPlayer(), horde), isNull);
  });
}
