import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/presentation/widgets/tech/tech_selection.dart';

Map<TechBranch, TechBranchState> states(Map<TechBranch, int> levels) => {
  for (final b in TechBranch.values)
    b: TechBranchState(
      branch: b,
      unlocked: levels.containsKey(b),
      researchLevel: levels[b] ?? 0),
};

void main() {
  group('TechSelection.suggested', () {
    test('nothing unlocked: first branch to unlock', () {
      expect(TechSelection.suggested(states({})),
        const TechSelection(TechBranch.military));
    });

    test('unlocked branch: its next research', () {
      expect(TechSelection.suggested(states({TechBranch.resources: 2})),
        const TechSelection(TechBranch.resources, 3));
    });

    test('maxed branch is skipped', () {
      expect(
        TechSelection.suggested(states({TechBranch.military: 5})),
        const TechSelection(TechBranch.resources));
    });

    test('everything maxed: last military node', () {
      expect(
        TechSelection.suggested(states({
          for (final b in TechBranch.values) b: 5,
        })),
        const TechSelection(TechBranch.military, 5));
    });
  });

  group('TechSelection.next', () {
    test('branch moves to its first node', () {
      expect(const TechSelection(TechBranch.explorer).next,
        const TechSelection(TechBranch.explorer, 1));
    });

    test('node moves to the following one', () {
      expect(const TechSelection(TechBranch.explorer, 2).next,
        const TechSelection(TechBranch.explorer, 3));
    });

    test('last node stays put', () {
      expect(const TechSelection(TechBranch.explorer, 5).next,
        const TechSelection(TechBranch.explorer, 5));
    });
  });
}
