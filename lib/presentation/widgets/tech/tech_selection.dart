import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_cost_calculator.dart';

/// What the player is looking at in the research reef: a whole branch
/// (to unlock it) or one research [level] of that branch.
class TechSelection {
  final TechBranch branch;
  final int? level;

  const TechSelection(this.branch, [this.level]);

  /// Selection to show once the selected target has been acquired.
  TechSelection get next {
    final l = level ?? 0;
    if (l >= TechCostCalculator.maxResearchLevel) return this;
    return TechSelection(branch, l + 1);
  }

  @override
  bool operator ==(Object other) =>
      other is TechSelection && other.branch == branch && other.level == level;

  @override
  int get hashCode => Object.hash(branch, level);
}
