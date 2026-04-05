import 'tech_branch.dart';
import 'tech_branch_state.dart';

class VisionCalculator {
  static const int baseRadius = 3;

  static int computeVisionRadius(
    Map<TechBranch, TechBranchState> techBranches,
  ) {
    final explorer = techBranches[TechBranch.explorer];
    final bonus = explorer?.researchLevel ?? 0;
    return baseRadius + bonus;
  }
}
