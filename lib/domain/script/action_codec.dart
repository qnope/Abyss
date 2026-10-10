import 'dart:math';

import '../action/attack_transition_base_action.dart';
import '../action/attack_volcanic_kernel_action.dart';
import '../action/choose_event_action.dart';
import '../action/collect_treasure_action.dart';
import '../action/descend_action.dart';
import '../action/explore_action.dart';
import '../action/fight_monster_action.dart';
import '../action/recruit_unit_action.dart';
import '../action/research_tech_action.dart';
import '../action/garrison_kernel_action.dart';
import '../action/send_reinforcements_action.dart';
import '../action/unlock_branch_action.dart';
import '../action/upgrade_building_action.dart';
import '../building/building_type.dart';
import '../replay/seeded_random.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_option.dart';
import '../unit/unit_type.dart';
import 'action_spec.dart';

/// Reads one action of a JSON scenario, such as
/// `{"do": "recruit", "unit": "guardian", "count": 5}`.
///
/// Every player action of the game has a verb; enum values use their Dart
/// names (`algaeFarm`, `military`, `harpoonist`...). An action that rolls
/// dice may carry a `seed`, written by an exported replay, to roll the
/// same dice as the game it comes from.
abstract final class ActionCodec {
  /// Throws a [FormatException] right away when the action is malformed,
  /// rather than in the middle of a game.
  static ActionSpec decode(Map<String, Object?> json) {
    final ActionSpec spec = _specOf(_Fields(json));
    spec(Random(0));
    return spec;
  }

  static ActionSpec _specOf(_Fields f) {
    return switch (f.text('do')) {
      'upgrade' => (_) => UpgradeBuildingAction(
            buildingType: f.enumOf(BuildingType.values, 'building')),
      'unlock' => (_) =>
          UnlockBranchAction(branch: f.enumOf(TechBranch.values, 'branch')),
      'research' => (_) => ResearchTechAction(
          branch: f.enumOf(TechBranch.values, 'branch'),
          option: f.json.containsKey('option')
              ? f.enumOf(TechOption.values, 'option')
              : TechOption.a),
      'recruit' => (_) => RecruitUnitAction(
          unitType: f.enumOf(UnitType.values, 'unit'),
          quantity: f.integer('count')),
      'explore' => (_) => ExploreAction(
          targetX: f.integer('x'), targetY: f.integer('y'), level: f.level),
      'collect' => (r) => CollectTreasureAction(
          targetX: f.integer('x'),
          targetY: f.integer('y'),
          level: f.level,
          random: f.rng(r)),
      'fight' => (r) => FightMonsterAction(
          targetX: f.integer('x'),
          targetY: f.integer('y'),
          level: f.level,
          selectedUnits: f.units,
          random: f.rng(r)),
      'attackBase' => (r) => AttackTransitionBaseAction(
          targetX: f.integer('x'),
          targetY: f.integer('y'),
          level: f.level,
          selectedUnits: f.units,
          random: f.rng(r)),
      'attackKernel' => (r) => AttackVolcanicKernelAction(
          targetX: f.integer('x'),
          targetY: f.integer('y'),
          level: f.level,
          selectedUnits: f.units,
          random: f.rng(r)),
      'descend' => (r) => DescendAction(
          transitionX: f.integer('x'),
          transitionY: f.integer('y'),
          fromLevel: f.level,
          selectedUnits: f.units,
          random: f.rng(r)),
      'reinforce' => (_) => SendReinforcementsAction(
          transitionX: f.integer('x'),
          transitionY: f.integer('y'),
          fromLevel: f.level,
          selectedUnits: f.units),
      'garrison' => (_) => GarrisonKernelAction(selectedUnits: f.units),
      'withdraw' => (_) =>
          GarrisonKernelAction(selectedUnits: f.units, withdraw: true),
      'event' => (_) => ChooseEventAction(accept: f.boolean('accept')),
      final String verb => throw FormatException('Action inconnue : $verb'),
    };
  }
}

class _Fields {
  final Map<String, Object?> json;

  const _Fields(this.json);

  /// The action's own generator when the JSON names its seed.
  Random rng(Random fallback) {
    final Object? seed = json['seed'];
    return seed is int ? SeededRandom(seed) : fallback;
  }

  int get level => json.containsKey('level') ? integer('level') : 1;

  Map<UnitType, int> get units {
    final Object? raw = json['units'];
    if (raw is! Map) throw const FormatException('Champ "units" attendu');
    return <UnitType, int>{
      for (final MapEntry<Object?, Object?> e in raw.entries)
        _enumNamed(UnitType.values, e.key.toString()): e.value as int,
    };
  }

  String text(String key) {
    final Object? value = json[key];
    if (value is String) return value;
    throw FormatException('Champ "$key" attendu');
  }

  bool boolean(String key) {
    final Object? value = json[key];
    if (value is bool) return value;
    throw FormatException('Champ booléen "$key" attendu');
  }

  int integer(String key) {
    final Object? value = json[key];
    if (value is int) return value;
    throw FormatException('Champ entier "$key" attendu');
  }

  T enumOf<T extends Enum>(List<T> values, String key) =>
      _enumNamed(values, text(key));

  static T _enumNamed<T extends Enum>(List<T> values, String name) {
    for (final T value in values) {
      if (value.name == name) return value;
    }
    throw FormatException('Valeur inconnue : $name');
  }
}
