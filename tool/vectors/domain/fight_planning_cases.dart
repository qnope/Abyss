import 'package:abyss/domain/fight/army_rehearsal.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../vector_json.dart';
import 'fight_sides.dart';
import 'vector_inputs.dart';

/// An army rehearsed against an enemy.
class PlannedFight {
  final Map<UnitType, int> army;
  final List<Combatant> Function() enemy;
  final UnitBoost boost;
  final bool needsAdmiral;

  const PlannedFight(
    this.army,
    this.enemy, {
    this.boost = UnitBoost.none,
    this.needsAdmiral = false,
  });

  ArmyRehearsal get rehearsal =>
      ArmyRehearsal(army, enemy, boost: boost, needsAdmiral: needsAdmiral);

  /// The army with [k] more harpoonists, their entry kept in its place.
  Map<UnitType, int> withHarpoonists(int k) => <UnitType, int>{
    ...army,
    UnitType.harpoonist: (army[UnitType.harpoonist] ?? 0) + k,
  };

  Map<String, Object?> toJson() => {
    'army': VectorJson.pairs(army),
    'boost': [boost.atkPercent, boost.defPercent, boost.hpPercent],
    'enemy': VectorInputs.runs(enemy()),
    'needsAdmiral': needsAdmiral,
  };
}

/// The armies and enemies of the planning vectors.
abstract final class FightPlanningCases {
  static const _harpoonist = UnitType.harpoonist, _guardian = UnitType.guardian;
  static const _admiral = UnitType.abyssAdmiral, _breaker = UnitType.domeBreaker;
  static const _military = UnitBoost(atkPercent: 60, defPercent: 60);
  static const _allIn = UnitBoost(atkPercent: 130, defPercent: 60, hpPercent: 35);

  static List<Combatant> _rodeurs() =>
      FightSides.lair(MonsterDifficulty.easy, null, 20);
  static List<Combatant> _hunters() =>
      FightSides.lair(MonsterDifficulty.medium, MonsterFamily.hunter, 48);

  /// Largest numbers of harpoonists `smallestWinning` may add.
  static const List<int> maxKs = <int>[-1, 0, 1, 5, 40, 300];

  static final List<PlannedFight> fights = <PlannedFight>[
    const PlannedFight({}, _rodeurs),
    const PlannedFight({_harpoonist: 2}, _rodeurs),
    const PlannedFight({_harpoonist: 10}, _rodeurs),
    const PlannedFight({_harpoonist: 11}, _rodeurs),
    const PlannedFight({_harpoonist: 7}, _rodeurs, boost: _military),
    const PlannedFight({_harpoonist: 9, UnitType.scout: 4}, _rodeurs),
    const PlannedFight({_guardian: 8, _harpoonist: 30}, _hunters),
    const PlannedFight({_guardian: 8, _harpoonist: 82}, _hunters),
    const PlannedFight(
      {_admiral: 1, _harpoonist: 13},
      GuardianFactory.forFaille,
      needsAdmiral: true,
    ),
    const PlannedFight({_admiral: 1, _harpoonist: 13}, GuardianFactory.forFaille),
    const PlannedFight(
      {_admiral: 1, _guardian: 6, _harpoonist: 8},
      GuardianFactory.forFaille,
      needsAdmiral: true,
    ),
    const PlannedFight(
      {_admiral: 2, _guardian: 10, _breaker: 10, _harpoonist: 80},
      GuardianFactory.forCheminee,
      boost: _military,
      needsAdmiral: true,
    ),
    const PlannedFight(
      {_admiral: 1, _guardian: 20, _harpoonist: 60, _breaker: 25},
      GuardianFactory.forVolcanicKernel,
      boost: _allIn,
      needsAdmiral: true,
    ),
  ];

  /// Armies, each an escort too, sent against the three targets.
  static const List<(Map<UnitType, int>, UnitBoost)> assaults = [
    ({_admiral: 1}, UnitBoost.none),
    ({_admiral: 1, _guardian: 6}, UnitBoost.none),
    ({_admiral: 1, _harpoonist: 13}, UnitBoost.none),
    ({_admiral: 1, _guardian: 6, _harpoonist: 31}, UnitBoost.none),
    ({_admiral: 1, _guardian: 6, _harpoonist: 40}, UnitBoost.none),
    ({_admiral: 1, _guardian: 6, _harpoonist: 40}, _military),
    ({_admiral: 1, _guardian: 6, _harpoonist: 112}, _military),
    ({_admiral: 2, _guardian: 15, _harpoonist: 110}, _military),
    ({_admiral: 1, _guardian: 20, _breaker: 25, _harpoonist: 70}, _allIn),
    ({_harpoonist: 60}, _allIn),
  ];
}
