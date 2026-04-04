import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_branch_state.dart';

void main() {
  group('TechBranchState', () {
    test('default construction: unlocked is false, researchLevel is 0', () {
      final state = TechBranchState(branch: TechBranch.military);

      expect(state.branch, TechBranch.military);
      expect(state.unlocked, isFalse);
      expect(state.researchLevel, 0);
    });

    test('construction with custom values', () {
      final state = TechBranchState(
        branch: TechBranch.resources,
        unlocked: true,
        researchLevel: 3,
      );

      expect(state.branch, TechBranch.resources);
      expect(state.unlocked, isTrue);
      expect(state.researchLevel, 3);
    });
  });
}
