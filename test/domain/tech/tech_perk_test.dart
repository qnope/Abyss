import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/tech/tech_perk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TechPerk.of', () {
    const a = TechOption.a;
    const b = TechOption.b;

    test('military options', () {
      const m = TechBranch.military;
      expect(TechPerk.of(m, 2, a), TechPerk.coralBlades);
      expect(TechPerk.of(m, 2, b), TechPerk.nacreShell);
      expect(TechPerk.of(m, 4, a), TechPerk.livingRampart);
      expect(TechPerk.of(m, 4, b), TechPerk.deepAssault);
    });

    test('resources options', () {
      const r = TechBranch.resources;
      expect(TechPerk.of(r, 2, a), TechPerk.intensiveFarming);
      expect(TechPerk.of(r, 2, b), TechPerk.deepDrilling);
      expect(TechPerk.of(r, 4, a), TechPerk.sealedChests);
      expect(TechPerk.of(r, 4, b), TechPerk.thriftyWorksites);
    });

    test('explorer options', () {
      const e = TechBranch.explorer;
      expect(TechPerk.of(e, 2, a), TechPerk.deepSonar);
      expect(TechPerk.of(e, 2, b), TechPerk.silentSwim);
      expect(TechPerk.of(e, 4, a), TechPerk.wreckRaiders);
      expect(TechPerk.of(e, 4, b), TechPerk.sentinels);
    });

    test('shared tiers grant no perk', () {
      for (final branch in TechBranch.values) {
        for (final level in const [1, 3, 5]) {
          expect(TechPerk.of(branch, level, a), isNull);
        }
      }
    });

    test('every perk belongs to exactly one node option', () {
      final all = [
        for (final branch in TechBranch.values)
          for (final level in const [2, 4])
            for (final option in TechOption.values)
              TechPerk.of(branch, level, option),
      ];
      expect(all.toSet(), TechPerk.values.toSet());
      expect(all, hasLength(TechPerk.values.length));
    });
  });
}
