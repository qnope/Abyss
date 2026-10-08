import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/tech/tech_perk.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';

const _a = TechOption.a;
const _b = TechOption.b;

void main() {
  group('TechEffects military', () {
    test('no research: no boost at all', () {
      final tech = effectsOf(const []);
      expect(tech.perks, isEmpty);
      final boost = tech.unitBoost(attacking: true, defendingBase: true);
      expect([boost.atkPercent, boost.defPercent, boost.hpPercent], [0, 0, 0]);
    });

    test('each tier gives +20% ATK and DEF', () {
      for (final (level, percent) in const [(1, 20), (3, 40), (5, 60)]) {
        final tech = effectsOf([
          researchedBranch(TechBranch.military, level, options: [_b, _b]),
        ]);
        expect(tech.tiersOf(TechBranch.military), level ~/ 2 + 1);
        expect(tech.defPercent(), percent);
        expect(tech.atkPercent(), percent);
      }
    });

    test('Lames de corail adds +35% ATK, always', () {
      final tech = effectsOf([
        researchedBranch(TechBranch.military, 2, options: [_a]),
      ]);
      expect(tech.has(TechPerk.coralBlades), isTrue);
      expect(tech.atkPercent(), 55);
      expect(tech.defPercent(), 20);
    });

    test('Carapace de nacre adds +35% HP', () {
      final tech = effectsOf([
        researchedBranch(TechBranch.military, 2, options: [_b]),
      ]);
      expect(tech.hpPercent, 35);
      expect(tech.unitBoost().hpPercent, 35);
      expect(tech.atkPercent(), 20);
    });

    test('Rempart vivant adds +35% DEF only defending the base', () {
      final tech = effectsOf([
        researchedBranch(TechBranch.military, 4, options: [_b, _a]),
      ]);
      expect(tech.defPercent(), 40);
      expect(tech.defPercent(defendingBase: true), 75);
      expect(tech.unitBoost(defendingBase: true).defPercent, 75);
      expect(tech.unitBoost(attacking: true).atkPercent, 40);
    });

    test('Assaut des profondeurs adds +35% ATK only attacking', () {
      final tech = effectsOf([
        researchedBranch(TechBranch.military, 4, options: [_b, _b]),
      ]);
      expect(tech.atkPercent(), 40);
      expect(tech.atkPercent(attacking: true), 75);
      expect(tech.unitBoost(attacking: true).atkPercent, 75);
      expect(tech.unitBoost(defendingBase: true).defPercent, 40);
    });

    test('a full branch stacks tiers and options', () {
      final tech = effectsOf([
        researchedBranch(TechBranch.military, 5, options: [_a, _b]),
      ]);
      final boost = tech.unitBoost(attacking: true);
      expect(boost.atkPercent, 60 + 35 + 35);
      expect(boost.defPercent, 60);
      expect(boost.hpPercent, 0);
    });

    test('a locked branch counts for nothing', () {
      final tech = effectsOf([
        researchedBranch(TechBranch.military, 5)..unlocked = false,
      ]);
      expect(tech.atkPercent(attacking: true), 0);
      expect(tech.perks, isEmpty);
    });

    test('other branches leave the units untouched', () {
      final tech = effectsOf([
        researchedBranch(TechBranch.resources, 5),
        researchedBranch(TechBranch.explorer, 5),
      ]);
      final boost = tech.unitBoost(attacking: true, defendingBase: true);
      expect([boost.atkPercent, boost.defPercent, boost.hpPercent], [0, 0, 0]);
    });
  });
}
