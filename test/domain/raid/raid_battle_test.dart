import 'dart:math';

import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_battle.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'raid_test_helper.dart';

void main() {
  const wave = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5);

  test('an empty base loses and is pillaged, pearls aside', () {
    final player = raidPlayer();
    final report = RaidBattle.fight(
        player: player, wave: wave, turn: 10, random: Random(1));
    expect(report.victory, isFalse);
    expect(report.defenders, isEmpty);
    expect(report.pillaged[ResourceType.coral], 300);
    expect(report.pillaged.containsKey(ResourceType.pearl), isFalse);
    expect(player.resources[ResourceType.coral]!.amount, 700);
    expect(player.resources[ResourceType.pearl]!.amount, 1000);
  });

  test('a strong garrison wins, keeps its units and earns loot', () {
    final player = raidPlayer(units: {UnitType.harpoonist: 30});
    final report = RaidBattle.fight(
        player: player, wave: wave, turn: 10, random: Random(1));
    expect(report.victory, isTrue);
    expect(report.defenders, {UnitType.harpoonist: 30});
    expect(report.pillaged, isEmpty);
    expect(report.loot[ResourceType.coral], inInclusiveRange(150, 250));
    final dead = report.dead[UnitType.harpoonist] ?? 0;
    expect(unitsOnBase(player), 30 - dead);
  });

  test('the Citadel rampart fights alongside the defenders', () {
    final player = raidPlayer(citadelLevel: 5);
    final report = RaidBattle.fight(
        player: player, wave: wave, turn: 10, random: Random(1));
    expect(report.rampartLevel, 5);
    expect(report.fight.initialPlayerCombatants, hasLength(1));
    expect(report.fight.initialPlayerCombatants.single.maxHp, 200);
  });

  test('units on deeper levels do not defend', () {
    final player = raidPlayer();
    player.unitsPerLevel[2] = {
      UnitType.harpoonist: Unit(type: UnitType.harpoonist, count: 10),
    };
    expect(RaidBattle.defendersOf(player), isEmpty);
  });
}
