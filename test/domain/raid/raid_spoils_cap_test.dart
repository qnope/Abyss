import 'dart:math';

import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_battle.dart';
import 'package:abyss/domain/raid/raid_spoils.dart';
import 'package:abyss/domain/resource/production_calculator.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'raid_test_helper.dart';

void main() {
  test('loot is capped at two turns of production, pearls aside', () {
    final capped = RaidSpoils.capToProduction(
      const {
        ResourceType.algae: 400,
        ResourceType.coral: 40,
        ResourceType.ore: 300,
        ResourceType.pearl: 2,
      },
      const {ResourceType.algae: 50, ResourceType.coral: 30},
    );
    expect(capped, {
      ResourceType.algae: 100,
      ResourceType.coral: 40,
      ResourceType.ore: 0,
      ResourceType.pearl: 2,
    });
  });

  test('a repelled raid brings no more than two turns of production', () {
    final player = raidPlayer(
      units: {UnitType.harpoonist: 30},
      headquartersLevel: 1,
    );
    final report = RaidBattle.fight(
      player: player,
      wave: const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5),
      turn: 10,
      random: Random(1),
    );
    final produced = ProductionCalculator.fromBuildings(player.buildings);
    expect(report.victory, isTrue);
    expect(report.loot[ResourceType.coral], 2 * produced[ResourceType.coral]!);
    expect(report.loot[ResourceType.ore], 2 * produced[ResourceType.ore]!);
  });
}
