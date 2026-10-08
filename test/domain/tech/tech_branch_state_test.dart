import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/tech/tech_perk.dart';

void main() {
  group('TechBranchState', () {
    test('default construction: unlocked is false, researchLevel is 0', () {
      final state = TechBranchState(branch: TechBranch.military);

      expect(state.branch, TechBranch.military);
      expect(state.unlocked, isFalse);
      expect(state.researchLevel, 0);
      expect(state.choices, isEmpty);
    });

    test('construction with custom values', () {
      final state = TechBranchState(
        branch: TechBranch.resources,
        unlocked: true,
        researchLevel: 3,
        choices: [TechOption.b.index],
      );

      expect(state.branch, TechBranch.resources);
      expect(state.unlocked, isTrue);
      expect(state.researchLevel, 3);
      expect(state.optionAt(2), TechOption.b);
    });
  });

  group('optionAt', () {
    TechBranchState at(int level, [List<int>? choices]) => TechBranchState(
      branch: TechBranch.explorer,
      unlocked: true,
      researchLevel: level,
      choices: choices,
    );

    test('is null on a tier level', () {
      expect(at(5, [1, 1]).optionAt(1), isNull);
      expect(at(5, [1, 1]).optionAt(3), isNull);
    });

    test('is null while the choice node is not researched', () {
      expect(at(1).optionAt(2), isNull);
      expect(at(3, [1]).optionAt(4), isNull);
    });

    test('an old save without choices defaults to option A', () {
      final old = at(5);
      expect(old.optionAt(2), TechOption.a);
      expect(old.optionAt(4), TechOption.a);
    });

    test('reads the option recorded for each node', () {
      final state = at(5, [TechOption.b.index, TechOption.a.index]);
      expect(state.optionAt(2), TechOption.b);
      expect(state.optionAt(4), TechOption.a);
    });
  });

  group('choose', () {
    test('records the option of a choice node', () {
      final state = TechBranchState(branch: TechBranch.military)
        ..choose(2, TechOption.b);
      expect(state.choices, [TechOption.b.index]);
    });

    test('fills the skipped nodes with option A', () {
      final state = TechBranchState(branch: TechBranch.military)
        ..choose(4, TechOption.b);
      expect(state.choices, [TechOption.a.index, TechOption.b.index]);
    });

    test('replaces an earlier choice of the same node', () {
      final state = TechBranchState(branch: TechBranch.military)
        ..choose(2, TechOption.b)
        ..choose(2, TechOption.a);
      expect(state.choices, [TechOption.a.index]);
    });
  });

  group('perks and tiers', () {
    test('a locked branch grants nothing', () {
      final state = TechBranchState(
          branch: TechBranch.military, researchLevel: 5, choices: [1, 1]);
      expect(state.perks, isEmpty);
      expect(state.tiers, 0);
    });

    test('perks follow the options taken at researched nodes', () {
      final state = TechBranchState(
        branch: TechBranch.military,
        unlocked: true,
        researchLevel: 4,
        choices: [TechOption.b.index, TechOption.a.index],
      );
      expect(state.perks, {TechPerk.nacreShell, TechPerk.livingRampart});
      expect(state.tiers, 2);
    });

    test('a node not yet researched grants no perk', () {
      final state = TechBranchState(
          branch: TechBranch.resources, unlocked: true, researchLevel: 3);
      expect(state.perks, {TechPerk.intensiveFarming});
      expect(state.tiers, 2);
    });

    test('tiers count levels 1, 3 and 5', () {
      int tiers(int level) => TechBranchState(
              branch: TechBranch.explorer,
              unlocked: true,
              researchLevel: level)
          .tiers;
      expect([for (var l = 0; l <= 5; l++) tiers(l)], [0, 1, 1, 2, 2, 3]);
    });
  });
}
