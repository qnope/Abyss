import '../../action/recruit_unit_action.dart';
import '../../building/building_type.dart';
import '../../fight/combatant.dart';
import '../../resource/consumption_calculator.dart';
import '../../resource/production_calculator.dart';
import '../../resource/resource_type.dart';
import '../../unit/unit_cost_calculator.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import 'army_planner.dart';

/// Recruiting by "mixes": a fixed ratio of unit types recruited together,
/// such as one Gardien for two Harponneurs.
extension RecruitMoves on ScriptTurn {
  /// Most mixes recruited in one go: beyond that a plan is never sane.
  static const int maxBatch = 150;

  int get barracksLevel => player.buildings[BuildingType.barracks]?.level ?? 0;

  /// Mixes the barracks can train this turn, from [candidates].
  List<Map<UnitType, int>> usableMixes(
          List<Map<UnitType, int>> candidates) =>
      <Map<UnitType, int>>[
        for (final Map<UnitType, int> mix in candidates)
          if (mix.keys.every((UnitType t) =>
              UnitCostCalculator().isUnlocked(t, barracksLevel) &&
              !player.recruitedUnitTypes.contains(t)))
            mix,
      ];

  /// How many times [mix] can be paid with [share] of the stocks, without
  /// letting the algae upkeep run away.
  int affordable(Map<UnitType, int> mix, {double share = 1}) {
    final UnitCostCalculator costs = UnitCostCalculator();
    int best = 1 << 30;
    for (final ResourceType r in ResourceType.values) {
      int perMix = 0;
      mix.forEach((t, n) => perMix += (costs.recruitmentCost(t)[r] ?? 0) * n);
      if (perMix == 0) continue;
      final int stock = ((player.resources[r]?.amount ?? 0) * share).floor();
      best = best < stock ~/ perMix ? best : stock ~/ perMix;
    }
    int upkeep = 0;
    mix.forEach((t, n) => upkeep += ConsumptionCalculator.unitAlgaeConsumption(t) * n);
    if (upkeep > 0) {
      final int room = algaeMargin + (player.resources[ResourceType.algae]?.amount ?? 0) ~/ 10;
      best = best < room ~/ upkeep ? best : room ~/ upkeep;
    }
    final int cap = barracksLevel * 100 ~/ mix.values.reduce((a, b) => a > b ? a : b);
    return [best, cap, maxBatch].reduce((a, b) => a < b ? a : b).clamp(0, 1 << 30);
  }

  /// Algae produced minus algae eaten each turn, all levels together.
  int get algaeMargin {
    final int produced = ProductionCalculator.fromBuildings(player.buildings,
            techBranches: player.techBranches)[ResourceType.algae] ??
        0;
    return produced -
        ConsumptionCalculator.totalUnitConsumptionAllLevels(
            player.unitsPerLevel);
  }

  bool recruitMix(Map<UnitType, int> mix, int k) {
    if (k <= 0) return false;
    bool all = true;
    mix.forEach((UnitType t, int n) {
      all = tryPerform(RecruitUnitAction(unitType: t, quantity: n * k)) && all;
    });
    return all;
  }

  /// Recruits the smallest top-up of the first of [mixes] (in order of
  /// preference) that lets [base] beat [enemy]; when none is enough,
  /// spends [share] on the first mix.
  /// Returns whether the army is judged strong enough afterwards.
  bool topUp({
    required Map<UnitType, int> base,
    required List<Combatant> Function() enemy,
    required List<Map<UnitType, int>> mixes,
    required ArmyPlanner planner,
    required int militaryLevel,
    List<Combatant> Function()? allies,
    bool needsAdmiral = false,
    double share = 1,
  }) {
    Map<UnitType, int> plus(Map<UnitType, int> mix, int k) =>
        <UnitType, int>{
          ...base,
          for (final e in mix.entries) e.key: (base[e.key] ?? 0) + e.value * k,
        };
    final List<Map<UnitType, int>> usable = usableMixes(mixes);
    for (final Map<UnitType, int> mix in usable) {
      final int? k = planner.smallestWinning(
          affordable(mix, share: share), (int k) => plus(mix, k), enemy,
          militaryLevel: militaryLevel,
          allies: allies,
          needsAdmiral: needsAdmiral);
      if (k == null) continue;
      return k == 0 || recruitMix(mix, k);
    }
    if (usable.isNotEmpty) {
      recruitMix(usable.first, affordable(usable.first, share: share));
    }
    return false;
  }
}
