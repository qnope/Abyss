import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';

const _a = TechOption.a;
const _b = TechOption.b;

void main() {
  group('TechEffects resources', () {
    test('defaults without research', () {
      final tech = effectsOf(const []);
      for (final type in ResourceType.values) {
        expect(tech.productionPercent(type), 0);
      }
      expect(tech.pillageRate, 0.3);
      expect(tech.upgradeDiscountPercent, 0);
    });

    test('each tier gives +20% on every resource', () {
      final tech = effectsOf([researchedBranch(TechBranch.resources, 3,
          options: [_a])]);
      expect(tech.productionPercent(ResourceType.ore), 40);
      expect(tech.productionPercent(ResourceType.pearl), 40);
    });

    test('Culture intensive adds +35% algae and coral', () {
      final tech = effectsOf([researchedBranch(TechBranch.resources, 2,
          options: [_a])]);
      expect(tech.productionPercent(ResourceType.algae), 55);
      expect(tech.productionPercent(ResourceType.coral), 55);
      expect(tech.productionPercent(ResourceType.ore), 20);
      expect(tech.productionPercent(ResourceType.energy), 20);
    });

    test('Forage profond adds +35% ore and energy', () {
      final tech = effectsOf([researchedBranch(TechBranch.resources, 2,
          options: [_b])]);
      expect(tech.productionPercent(ResourceType.ore), 55);
      expect(tech.productionPercent(ResourceType.energy), 55);
      expect(tech.productionPercent(ResourceType.algae), 20);
    });

    test('Coffres scellés halves the pillage rate', () {
      final tech = effectsOf([researchedBranch(TechBranch.resources, 4,
          options: [_a, _a])]);
      expect(tech.pillageRate, 0.15);
      expect(tech.upgradeDiscountPercent, 0);
    });

    test('Chantiers économes discounts upgrades by 15%', () {
      final tech = effectsOf([researchedBranch(TechBranch.resources, 4,
          options: [_a, _b])]);
      expect(tech.upgradeDiscountPercent, 15);
      expect(tech.pillageRate, 0.3);
    });
  });

  group('TechEffects explorer', () {
    test('defaults without research', () {
      final tech = effectsOf(const []);
      expect(tech.revealSide, 3);
      expect(tech.muffle(4), 4);
      expect(tech.lootPercent, 100);
      expect(tech.raidWarningTurns, 2);
    });

    test('each tier widens the revealed square by 2', () {
      final tech = effectsOf([researchedBranch(TechBranch.explorer, 5,
          options: [_b, _b])]);
      expect(tech.revealSide, 9);
    });

    test('Sonar profond widens it by 2 more', () {
      final tech = effectsOf([researchedBranch(TechBranch.explorer, 2,
          options: [_a])]);
      expect(tech.revealSide, 7);
    });

    test('Nage silencieuse muffles every noise', () {
      final tech = effectsOf([researchedBranch(TechBranch.explorer, 2,
          options: [_b])]);
      expect(tech.muffle(4), 0);
      expect(tech.revealSide, 5);
    });

    test("Pillards d'épaves gives +50% loot", () {
      final tech = effectsOf([researchedBranch(TechBranch.explorer, 4,
          options: [_a, _a])]);
      expect(tech.lootPercent, 150);
      expect(tech.boostLoot({ResourceType.ore: 10, ResourceType.pearl: 3}),
          {ResourceType.ore: 15, ResourceType.pearl: 4});
    });

    test('Sentinelles announce raids 4 turns ahead', () {
      final tech = effectsOf([researchedBranch(TechBranch.explorer, 4,
          options: [_a, _b])]);
      expect(tech.raidWarningTurns, 4);
      expect(tech.lootPercent, 100);
    });
  });
}
