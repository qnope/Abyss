import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Builds the objects the rules take from what a vector case writes.
abstract final class VectorInputs {
  /// Storage of the stocks of a new player (`PlayerDefaults.resources`).
  static const Map<ResourceType, int> storage = <ResourceType, int>{
    ResourceType.algae: 5000,
    ResourceType.coral: 5000,
    ResourceType.ore: 5000,
    ResourceType.energy: 2000,
    ResourceType.pearl: 100,
  };

  /// Every building in the order of `BuildingType.values`, at the level
  /// [levels] gives it, 0 otherwise: the buildings of a player.
  static Map<BuildingType, Building> buildings(Map<BuildingType, int> levels) =>
      {
        for (final BuildingType type in BuildingType.values)
          type: Building(type: type, level: levels[type] ?? 0),
      };

  /// The five stocks in the order of `ResourceType.values`, holding
  /// [amounts] (0 otherwise) under the [storage] of a new player.
  static Map<ResourceType, Resource> resources(Map<ResourceType, int> amounts) =>
      {
        for (final ResourceType type in ResourceType.values)
          type: Resource(
            type: type,
            amount: amounts[type] ?? 0,
            maxStorage: storage[type]!,
          ),
      };

  /// The six units in the order of `UnitType.values`, [counts] of each.
  static Map<UnitType, Unit> units(Map<UnitType, int> counts) => {
    for (final UnitType type in UnitType.values)
      type: Unit(type: type, count: counts[type] ?? 0),
  };

  /// The three branches in the order of `TechBranch.values`. A branch of
  /// [research] is unlocked, at the level and with the choices (option
  /// indices) given; the others are locked.
  static Map<TechBranch, TechBranchState> tech(
    Map<TechBranch, (int, List<int>)> research,
  ) => {
    for (final TechBranch branch in TechBranch.values)
      branch: TechBranchState(
        branch: branch,
        unlocked: research.containsKey(branch),
        researchLevel: research[branch]?.$1 ?? 0,
        choices: research[branch]?.$2,
      ),
  };

  /// [research] as a case writes it: `{branch: [level, choices]}`.
  static Map<TechBranch, List<Object>> techJson(
    Map<TechBranch, (int, List<int>)> research,
  ) => {
    for (final e in research.entries) e.key: [e.value.$1, e.value.$2],
  };

  /// A combatant as a case writes it: type key, side, max HP, ATK, DEF,
  /// current HP, boss.
  static List<Object> combatant(Combatant c) => [
    c.typeKey, c.side, c.maxHp, c.atk, c.def, c.currentHp, c.isBoss,
  ];

  /// A side of fresh combatants as a case writes it: each run of
  /// identical ones as type key, side, max HP, ATK, DEF, boss, count.
  static List<List<Object>> runs(List<Combatant> side) {
    final List<List<Object>> runs = <List<Object>>[];
    String? last;
    for (final Combatant c in side) {
      if (c.currentHp != c.maxHp) throw ArgumentError('not fresh');
      final List<Object> run = [
        c.typeKey, c.side, c.maxHp, c.atk, c.def, c.isBoss, 1,
      ];
      final String key = '${run.sublist(0, 6)}';
      if (key == last) {
        runs.last[6] = (runs.last[6] as int) + 1;
      } else {
        runs.add(run);
      }
      last = key;
    }
    return runs;
  }
}
