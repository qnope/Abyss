import '../../action/fight_monster_helpers.dart';
import '../../building/building_cost_calculator.dart';
import '../../building/building_type.dart';
import '../../game/player.dart';
import '../../unit/unit_type.dart';
import '../unit_boost.dart';
import 'assault_chance.dart';
import 'assault_next_step.dart';
import 'assault_rehearsals.dart';
import 'assault_target.dart';

/// What the player should know before assaulting a Faille, a Cheminée or
/// the volcanic kernel with the army being composed: is an Abyss Admiral
/// in it and covered, how likely the capture is, what comes after, and
/// the army the guide advises.
///
/// Purely informative: it never changes the player, and it is cheap to
/// recompute at every unit added or removed (see [AssaultRehearsals]).
class AssaultPlan {
  /// Rehearsals behind every [chance].
  static int get rehearsals => AssaultRehearsals.planner.rehearsals;

  /// Most Harpoonists ever advised by default: enough for the kernel
  /// without any research (about 260 with a lone admiral).
  static const int defaultMaxHarpoonists = 300;

  final AssaultTarget target;

  /// The army being composed, without empty entries.
  final Map<UnitType, int> army;

  /// Abyss Admirals the player has on the level of the assault.
  final int admiralsAvailable;

  /// The building to raise after the capture; `null` for the kernel.
  final AssaultNextStep? nextStep;

  final UnitBoost _boost;
  final int _maxHarpoonists;

  AssaultPlan._(this.target, this.army, this.admiralsAvailable,
      this.nextStep, this._boost, this._maxHarpoonists);

  /// The plan for [player] sending [army] against [target] from [level],
  /// with the attacker boosts the real assault uses. The advice adds at
  /// most [maxHarpoonists].
  factory AssaultPlan.of({
    required Player player,
    required int level,
    required AssaultTarget target,
    required Map<UnitType, int> army,
    int maxHarpoonists = defaultMaxHarpoonists,
  }) =>
      AssaultPlan._(
        target,
        Map<UnitType, int>.unmodifiable(
            <UnitType, int>{...army}..removeWhere((_, int n) => n <= 0)),
        player.unitsOnLevel(level)[UnitType.abyssAdmiral]?.count ?? 0,
        _nextStepOf(player, target),
        FightMonsterHelpers.unitBoostOf(player, attacking: true),
        maxHarpoonists,
      );

  int get _admirals => army[UnitType.abyssAdmiral] ?? 0;
  int get _guardians => army[UnitType.guardian] ?? 0;

  /// Whether the army holds an Abyss Admiral, without whom nothing is
  /// captured.
  bool get hasAdmiral => _admirals > 0;

  /// Whether a Guardian marches with the admiral: Guardians draw the
  /// blows, so they keep the 0-attack admiral alive longer.
  bool get admiralCovered => _guardians > 0;

  /// How often the army captures the target; [AssaultChance.none] without
  /// an admiral.
  late final AssaultChance chance = hasAdmiral
      ? AssaultRehearsals.chanceOf(army, target, _boost)
      : AssaultChance.none;

  /// Fewest Harpoonists to send with the admirals (one if none is
  /// selected) and Guardians selected, for a capture in 19 rehearsals of
  /// 20; `null` when out of reach. Computed on first read.
  late final int? suggestedHarpoonists = AssaultRehearsals.harpoonistsFor(
    _escort,
    target,
    _boost,
    maxAdded: _maxHarpoonists,
  );

  /// The escort plus [suggestedHarpoonists]; `null` when out of reach.
  Map<UnitType, int>? get suggestedArmy {
    final int? harpoonists = suggestedHarpoonists;
    if (harpoonists == null) return null;
    return <UnitType, int>{
      ..._escort,
      if (harpoonists > 0) UnitType.harpoonist: harpoonists,
    };
  }

  Map<UnitType, int> get _escort => <UnitType, int>{
        UnitType.abyssAdmiral: hasAdmiral ? _admirals : 1,
        if (_guardians > 0) UnitType.guardian: _guardians,
      };

  static AssaultNextStep? _nextStepOf(Player player, AssaultTarget target) {
    final BuildingType? passage = target.passage;
    if (passage == null) return null;
    return AssaultNextStep(
      building: passage,
      requiredHq: const BuildingCostCalculator()
              .prerequisites(passage, 1)[BuildingType.headquarters] ??
          0,
      currentHq: player.buildings[BuildingType.headquarters]?.level ?? 0,
    );
  }
}
