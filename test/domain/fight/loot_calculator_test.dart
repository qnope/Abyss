import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/fight/loot_calculator.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  group('LootCalculator.compute', () {
    const ranges = {
      MonsterDifficulty.easy: (300, 500),
      MonsterDifficulty.medium: (500, 1000),
      MonsterDifficulty.hard: (1000, 2000),
    };

    const pearls = {
      MonsterDifficulty.easy: 0,
      MonsterDifficulty.medium: 2,
      MonsterDifficulty.hard: 10,
    };

    for (final difficulty in MonsterDifficulty.values) {
      test('$difficulty returns all resources in range across 50 seeds', () {
        final range = ranges[difficulty]!;
        final expectedPearl = pearls[difficulty]!;
        for (var seed = 0; seed < 50; seed++) {
          final calc = LootCalculator(random: Random(seed));
          final loot = calc.compute(difficulty);

          expect(loot.containsKey(ResourceType.algae), isTrue);
          expect(loot.containsKey(ResourceType.coral), isTrue);
          expect(loot.containsKey(ResourceType.ore), isTrue);
          expect(loot.containsKey(ResourceType.pearl), isTrue);

          for (final type in [
            ResourceType.algae,
            ResourceType.coral,
            ResourceType.ore,
          ]) {
            final amount = loot[type]!;
            expect(
              amount >= range.$1 && amount <= range.$2,
              isTrue,
              reason: '$type=$amount out of ${range.$1}-${range.$2} '
                  'for $difficulty (seed $seed)',
            );
          }

          expect(loot[ResourceType.pearl], expectedPearl);
        }
      });
    }

    test('easy with Random(42) returns deterministic tuple', () {
      final calc = LootCalculator(random: Random(42));
      final loot = calc.compute(MonsterDifficulty.easy);
      expect(loot[ResourceType.algae], 475);
      expect(loot[ResourceType.coral], 459);
      expect(loot[ResourceType.ore], 420);
      expect(loot[ResourceType.pearl], 0);
    });

    test('medium with Random(42) returns deterministic tuple', () {
      final calc = LootCalculator(random: Random(42));
      final loot = calc.compute(MonsterDifficulty.medium);
      expect(loot[ResourceType.algae], 528);
      expect(loot[ResourceType.coral], 620);
      expect(loot[ResourceType.ore], 830);
      expect(loot[ResourceType.pearl], 2);
    });

    test('hard with Random(42) returns deterministic tuple', () {
      final calc = LootCalculator(random: Random(42));
      final loot = calc.compute(MonsterDifficulty.hard);
      expect(loot[ResourceType.algae], 1671);
      expect(loot[ResourceType.coral], 1918);
      expect(loot[ResourceType.ore], 1292);
      expect(loot[ResourceType.pearl], 10);
    });

    test('default constructor uses a fresh Random', () {
      final calc = LootCalculator();
      final loot = calc.compute(MonsterDifficulty.medium);
      expect(loot.length, 4);
      expect(loot[ResourceType.pearl], 2);
    });
  });
}
