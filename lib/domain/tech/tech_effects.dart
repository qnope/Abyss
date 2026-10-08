import '../fight/unit_boost.dart';
import '../resource/resource_type.dart';
import 'tech_branch.dart';
import 'tech_branch_state.dart';
import 'tech_perk.dart';

/// Everything a player's research changes in the rules, read from the
/// tiers and options of the three branches.
class TechEffects {
  /// Bonus of each shared tier of a branch, in percent.
  static const int tierPercent = 20;

  final Map<TechBranch, int> _tiers;
  final Set<TechPerk> perks;

  TechEffects(Map<TechBranch, TechBranchState> techBranches)
    : _tiers = {
        for (final e in techBranches.entries) e.key: e.value.tiers,
      },
      perks = {for (final s in techBranches.values) ...s.perks};

  int tiersOf(TechBranch branch) => _tiers[branch] ?? 0;

  bool has(TechPerk perk) => perks.contains(perk);

  /// ATK bonus of every unit, in percent, plus Assaut on offence.
  int atkPercent({bool attacking = false}) =>
      tiersOf(TechBranch.military) * tierPercent +
      (has(TechPerk.coralBlades) ? 35 : 0) +
      (attacking && has(TechPerk.deepAssault) ? 35 : 0);

  /// DEF bonus of every unit, in percent, plus Rempart on the base.
  int defPercent({bool defendingBase = false}) =>
      tiersOf(TechBranch.military) * tierPercent +
      (defendingBase && has(TechPerk.livingRampart) ? 35 : 0);

  int get hpPercent => has(TechPerk.nacreShell) ? 35 : 0;

  /// Stat boosts of the units, on offence or guarding the base.
  UnitBoost unitBoost({bool attacking = false, bool defendingBase = false}) =>
      UnitBoost(
        atkPercent: atkPercent(attacking: attacking),
        defPercent: defPercent(defendingBase: defendingBase),
        hpPercent: hpPercent,
      );

  /// Production bonus on [type], in percent.
  int productionPercent(ResourceType type) {
    final farming = type == ResourceType.algae || type == ResourceType.coral;
    final drilling = type == ResourceType.ore || type == ResourceType.energy;
    return tiersOf(TechBranch.resources) * tierPercent +
        (farming && has(TechPerk.intensiveFarming) ? 35 : 0) +
        (drilling && has(TechPerk.deepDrilling) ? 35 : 0);
  }

  /// Share of the stocks a lost raid carries away.
  double get pillageRate => has(TechPerk.sealedChests) ? 0.15 : 0.3;

  /// Discount on building upgrades, in percent.
  int get upgradeDiscountPercent =>
      has(TechPerk.thriftyWorksites) ? 15 : 0;

  /// Side of the square an exploration reveals.
  int get revealSide =>
      3 + 2 * tiersOf(TechBranch.explorer) + (has(TechPerk.deepSonar) ? 2 : 0);

  /// Noise an exploration or a fight really makes: none once silent.
  int muffle(int noise) => has(TechPerk.silentSwim) ? 0 : noise;

  /// Loot multiplier, in percent, of lairs, ruins and transition bases.
  int get lootPercent => has(TechPerk.wreckRaiders) ? 150 : 100;

  /// Turns between a raid announcement and its arrival.
  int get raidWarningTurns => has(TechPerk.sentinels) ? 4 : 2;

  /// Scales every amount of [loot] by [lootPercent].
  Map<ResourceType, int> boostLoot(Map<ResourceType, int> loot) =>
      loot.map((t, v) => MapEntry(t, v * lootPercent ~/ 100));
}
