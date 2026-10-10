import '../../domain/tech/tech_branch.dart';
import '../../domain/tech/tech_option.dart';
import '../l10n/app_localizations.dart';

/// Name, effect and icon of every node of the research reef. A node is a
/// branch [level], plus the [TechOption] on a choice level (2 and 4).
extension TechNodeInfo on TechBranch {
  String nodeName(AppLocalizations l10n, int level, [TechOption? option]) =>
      _info(l10n, level, option).$1;

  String nodeEffect(AppLocalizations l10n, int level, [TechOption? option]) =>
      _info(l10n, level, option).$2;

  String nodeIconPath(int level, [TechOption? option]) =>
      'assets/icons/tech/${name}_$level${option?.name ?? ''}.svg';

  (String, String) _info(AppLocalizations l10n, int level, TechOption? option) {
    final tier = l10n.techTierEffect;
    final prod = l10n.techProductionEffect;
    return switch ((this, '$level${option?.name ?? ''}')) {
      (TechBranch.military, '1') => (l10n.techMilitary1Name, tier),
      (TechBranch.military, '2a') =>
        (l10n.techMilitary2aName, l10n.techMilitary2aEffect),
      (TechBranch.military, '2b') =>
        (l10n.techMilitary2bName, l10n.techMilitary2bEffect),
      (TechBranch.military, '3') => (l10n.techMilitary3Name, tier),
      (TechBranch.military, '4a') =>
        (l10n.techMilitary4aName, l10n.techMilitary4aEffect),
      (TechBranch.military, '4b') =>
        (l10n.techMilitary4bName, l10n.techMilitary4bEffect),
      (TechBranch.military, '5') => (l10n.techMilitary5Name, tier),
      (TechBranch.resources, '1') => (l10n.techResources1Name, prod),
      (TechBranch.resources, '2a') =>
        (l10n.techResources2aName, l10n.techResources2aEffect),
      (TechBranch.resources, '2b') =>
        (l10n.techResources2bName, l10n.techResources2bEffect),
      (TechBranch.resources, '3') => (l10n.techResources3Name, prod),
      (TechBranch.resources, '4a') =>
        (l10n.techResources4aName, l10n.techResources4aEffect),
      (TechBranch.resources, '4b') =>
        (l10n.techResources4bName, l10n.techResources4bEffect),
      (TechBranch.resources, '5') => (l10n.techResources5Name, prod),
      (TechBranch.explorer, '1') =>
        (l10n.techExplorer1Name, l10n.techExploredAreaEffect(5)),
      (TechBranch.explorer, '2a') =>
        (l10n.techExplorer2aName, l10n.techExplorer2aEffect),
      (TechBranch.explorer, '2b') =>
        (l10n.techExplorer2bName, l10n.techExplorer2bEffect),
      (TechBranch.explorer, '3') =>
        (l10n.techExplorer3Name, l10n.techExploredAreaEffect(7)),
      (TechBranch.explorer, '4a') =>
        (l10n.techExplorer4aName, l10n.techExplorer4aEffect),
      (TechBranch.explorer, '4b') =>
        (l10n.techExplorer4bName, l10n.techExplorer4bEffect),
      (TechBranch.explorer, '5') =>
        (l10n.techExplorer5Name, l10n.techExploredAreaEffect(9)),
      _ => ('', ''),
    };
  }
}
