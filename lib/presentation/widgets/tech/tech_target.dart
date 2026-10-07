import '../../../domain/tech/tech_branch.dart';

/// Something the player can act on in the research reef: a whole branch
/// (to unlock it) or one research [level] of that branch.
class TechTarget {
  final TechBranch branch;
  final int? level;

  const TechTarget(this.branch, [this.level]);

  @override
  bool operator ==(Object other) =>
      other is TechTarget && other.branch == branch && other.level == level;

  @override
  int get hashCode => Object.hash(branch, level);
}
