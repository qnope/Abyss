import 'dart:math';

import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/raid/raid_battle.dart';
import 'package:abyss/domain/raid/raid_resolver.dart';
import 'package:abyss/domain/raid/raid_spoils.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';
import 'raid_test_helper.dart';

const _a = TechOption.a;
const _b = TechOption.b;

/// [player] with its [branch] researched to level 4 with [options].
Player _with(Player player, TechBranch branch, List<TechOption> options) {
  player.techBranches[branch] =
      researchedBranch(branch, 4, options: options);
  return player;
}

void main() {
  const wave = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5);

  group('Coffres scellés', () {
    test('a lost raid pillages 15% instead of 30%', () {
      final player = _with(raidPlayer(), TechBranch.resources, [_a, _a]);
      final report = RaidBattle.fight(
          player: player, wave: wave, turn: 10, random: Random(1));

      expect(report.victory, isFalse);
      expect(report.pillaged[ResourceType.coral], 150);
      expect(player.resources[ResourceType.coral]!.amount, 850);
      expect(report.pillaged.containsKey(ResourceType.pearl), isFalse);
    });

    test('Chantiers économes leaves the pillage at 30%', () {
      final player = _with(raidPlayer(), TechBranch.resources, [_a, _b]);
      final report = RaidBattle.fight(
          player: player, wave: wave, turn: 10, random: Random(1));

      expect(report.pillaged[ResourceType.coral], 300);
    });

    test('RaidSpoils.pillage takes the rate it is given', () {
      final player = raidPlayer();
      final taken = RaidSpoils.pillage(player.resources, rate: 0.15);
      expect(taken[ResourceType.ore], 150);
      expect(player.resources[ResourceType.ore]!.amount, 850);
    });
  });

  group('Sentinelles', () {
    test('a raid is announced four turns ahead', () {
      final player = _with(raidPlayer(), TechBranch.explorer, [_a, _b])
        ..raidState.addNoise(NoiseRules.threshold);
      final outcome = RaidResolver.resolve(player, 12);

      expect(outcome.announcedTurn, 16);
      expect(player.raidState.arrivalTurn, 16);
    });

    test("Pillards d'épaves keeps the two-turn warning", () {
      final player = _with(raidPlayer(), TechBranch.explorer, [_a, _a])
        ..raidState.addNoise(NoiseRules.threshold);

      expect(RaidResolver.resolve(player, 12).announcedTurn, 14);
    });
  });

  group("Pillards d'épaves", () {
    test('a repelled raid yields 50% more loot', () {
      Map<ResourceType, int> lootOf(Player player) => RaidBattle.fight(
              player: player, wave: wave, turn: 10, random: Random(1))
          .loot;
      final plain = lootOf(raidPlayer(units: {UnitType.harpoonist: 30}));
      final raider = lootOf(_with(raidPlayer(units: {UnitType.harpoonist: 30}),
          TechBranch.explorer, [_a, _a]));

      expect(plain, isNotEmpty);
      for (final type in plain.keys) {
        expect(raider[type], plain[type]! * 150 ~/ 100);
      }
    });
  });
}
