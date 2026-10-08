import 'package:hive_ce/hive.dart';
import 'tech_branch.dart';
import 'tech_option.dart';
import 'tech_perk.dart';
import 'tech_tree.dart';

part 'tech_branch_state.g.dart';

@HiveType(typeId: 7)
class TechBranchState extends HiveObject {
  @HiveField(0)
  final TechBranch branch;

  @HiveField(1)
  bool unlocked;

  @HiveField(2)
  int researchLevel; // 0 = none, 1–5 = researched nodes

  /// Option index (see [TechOption]) taken at each choice node, in order.
  /// A save older than the choices has none: option A is assumed.
  @HiveField(3)
  List<int> choices;

  TechBranchState({
    required this.branch,
    this.unlocked = false,
    this.researchLevel = 0,
    List<int>? choices,
  }) : choices = choices ?? <int>[];

  /// Option taken at the choice node of [level], `null` when that node is
  /// not researched yet.
  TechOption? optionAt(int level) {
    if (!TechTree.isChoiceLevel(level) || level > researchLevel) return null;
    final index = TechTree.choiceIndex(level);
    if (index >= choices.length) return TechOption.a;
    return TechOption.values[choices[index]];
  }

  /// Records [option] for the choice node of [level].
  void choose(int level, TechOption option) {
    final index = TechTree.choiceIndex(level);
    while (choices.length <= index) {
      choices = [...choices, TechOption.a.index];
    }
    choices = [...choices]..[index] = option.index;
  }

  /// Perks taken in this branch, none while it is locked.
  Set<TechPerk> get perks => {
    if (unlocked)
      for (var l = 2; l <= researchLevel; l += 2)
        TechPerk.of(branch, l, optionAt(l)!)!,
  };

  /// Shared tiers (levels 1, 3, 5) researched, none while locked.
  int get tiers => unlocked ? TechTree.tiersReached(researchLevel) : 0;
}
