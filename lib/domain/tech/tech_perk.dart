import 'tech_branch.dart';
import 'tech_option.dart';
import 'tech_tree.dart';

/// Effect of one option of a choice node, two per branch level 2 and 4.
enum TechPerk {
  coralBlades, nacreShell, livingRampart, deepAssault,
  intensiveFarming, deepDrilling, sealedChests, thriftyWorksites,
  deepSonar, silentSwim, wreckRaiders, sentinels;

  /// The perk granted by [option] at the choice node of [level], or
  /// `null` when [level] is a shared tier.
  static TechPerk? of(TechBranch branch, int level, TechOption option) {
    if (!TechTree.isChoiceLevel(level)) return null;
    final perks = _byBranch[branch]!;
    return perks[TechTree.choiceIndex(level) * 2 + option.index];
  }

  static const Map<TechBranch, List<TechPerk>> _byBranch = {
    TechBranch.military: [coralBlades, nacreShell, livingRampart, deepAssault],
    TechBranch.resources: [
      intensiveFarming, deepDrilling, sealedChests, thriftyWorksites,
    ],
    TechBranch.explorer: [deepSonar, silentSwim, wreckRaiders, sentinels],
  };
}
