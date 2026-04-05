import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_branch_state.dart';
import 'package:abyss/domain/vision_calculator.dart';

void main() {
  group('VisionCalculator', () {
    test('base radius is 3 with no explorer research', () {
      final branches = {
        TechBranch.military: TechBranchState(branch: TechBranch.military),
        TechBranch.resources: TechBranchState(branch: TechBranch.resources),
        TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
      };
      expect(VisionCalculator.computeVisionRadius(branches), 3);
    });

    test('radius increases with explorer research level', () {
      final explorer = TechBranchState(branch: TechBranch.explorer);
      explorer.researchLevel = 3;
      final branches = {
        TechBranch.military: TechBranchState(branch: TechBranch.military),
        TechBranch.resources: TechBranchState(branch: TechBranch.resources),
        TechBranch.explorer: explorer,
      };
      expect(VisionCalculator.computeVisionRadius(branches), 6);
    });

    test('max radius is 8 at explorer level 5', () {
      final explorer = TechBranchState(branch: TechBranch.explorer);
      explorer.researchLevel = 5;
      final branches = {
        TechBranch.military: TechBranchState(branch: TechBranch.military),
        TechBranch.resources: TechBranchState(branch: TechBranch.resources),
        TechBranch.explorer: explorer,
      };
      expect(VisionCalculator.computeVisionRadius(branches), 8);
    });
  });
}
