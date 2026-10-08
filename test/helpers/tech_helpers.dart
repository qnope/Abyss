import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/tech/tech_effects.dart';
import 'package:abyss/domain/tech/tech_option.dart';

/// An unlocked [branch] researched up to [level], with [options] taken at
/// its choice nodes (levels 2 then 4).
TechBranchState researchedBranch(
  TechBranch branch,
  int level, {
  List<TechOption> options = const [],
}) {
  return TechBranchState(
    branch: branch,
    unlocked: true,
    researchLevel: level,
    choices: [for (final o in options) o.index],
  );
}

/// All three branches, locked unless given in [states].
Map<TechBranch, TechBranchState> techBranchesWith(
  List<TechBranchState> states,
) {
  return {
    for (final b in TechBranch.values) b: TechBranchState(branch: b),
    for (final s in states) s.branch: s,
  };
}

/// Effects of [states] (other branches locked).
TechEffects effectsOf(List<TechBranchState> states) =>
    TechEffects(techBranchesWith(states));
