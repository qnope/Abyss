import 'package:abyss/domain/building/coral_citadel_rampart.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/leviathan/leviathan_force.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/magma_rampart.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';

import 'fight_sides.dart';

typedef _Side = List<Combatant> Function();

/// The fights of the vectors, built as the game builds them: every unit
/// role, every monster family and rule, both ramparts, the guardians.
abstract final class FightScenarios {
  static const _scout = UnitType.scout, _harpoonist = UnitType.harpoonist;
  static const _guardian = UnitType.guardian, _breaker = UnitType.domeBreaker;
  static const _admiral = UnitType.abyssAdmiral, _saboteur = UnitType.saboteur;
  static const _easy = MonsterDifficulty.easy, _hard = MonsterDifficulty.hard;
  static const _medium = MonsterDifficulty.medium;
  static const _research = UnitBoost(
    atkPercent: 95,
    defPercent: 60,
    hpPercent: 35,
  );

  static const Map<UnitType, int> _everyUnit = {
    _scout: 6, _harpoonist: 25, _guardian: 10, _breaker: 12,
    _admiral: 1, _saboteur: 8,
  };

  /// Name of the fight, then the player side and the monster side.
  static final Map<String, (_Side, _Side)> all = {
    'no one': (() => [], () => []),
    'no monster': (() => _units({_scout: 2}), () => []),
    'no player': (() => [], () => _lair(_easy, null, 3)),
    'duel': (() => _units({_harpoonist: 1}), () => _lair(_easy, null, 1)),
    'admiral alone': (() => _units({_admiral: 1}), () => _lair(_easy, null, 4)),
    'generic easy': (() => _units({_harpoonist: 12}), () => _lair(_easy, null, 20)),
    'generic medium': (
      () => _units({_harpoonist: 30, _guardian: 8}),
      () => _lair(_medium, null, 25),
    ),
    'generic hard': (() => _units(_everyUnit), () => _lair(_hard, null, 30)),
    'harpoons sweep a swarm': (
      () => _units({_harpoonist: 20}),
      () => _lair(_easy, MonsterFamily.swarm, 90),
    ),
    'scouts flee hunters': (
      () => _units({_scout: 10, _harpoonist: 6}),
      () => _lair(_easy, MonsterFamily.hunter, 16),
    ),
    'guardians draw hunters': (
      () => _units({_harpoonist: 30, _guardian: 10}),
      () => _lair(_medium, MonsterFamily.hunter, 50),
    ),
    'harpoons scratch armour': (
      () => _units({_harpoonist: 30}),
      () => _lair(_easy, MonsterFamily.armoured, 14),
    ),
    'saboteurs pierce armour': (
      () => _units({_saboteur: 15, _guardian: 4}),
      () => _lair(_medium, MonsterFamily.armoured, 40),
    ),
    'breakers hit colossi': (
      () => _units({_breaker: 20, _guardian: 10}),
      () => _lair(_medium, MonsterFamily.colossus, 10),
    ),
    'every unit, boosted': (
      () => _units(_everyUnit, boost: _research),
      () => _lair(_hard, MonsterFamily.colossus, 20),
    ),
    'outnumbered': (
      () => _units({_scout: 2, _harpoonist: 3}),
      () => _lair(_hard, MonsterFamily.hunter, 60),
    ),
    'raid on a rampart': (
      () => [
        ..._units({_harpoonist: 14, _guardian: 4, _breaker: 3}),
        CoralCitadelRampart.combatantFor(3)!,
      ],
      () => _lair(_medium, MonsterFamily.swarm, 30, MonsterFamily.colossus, 2),
    ),
    'raid on a worn rampart': (
      () => [
        ..._units({_scout: 4, _harpoonist: 9}),
        CoralCitadelRampart.combatantFor(5, degraded: true)!,
      ],
      () => _lair(_easy, MonsterFamily.hunter, 8, MonsterFamily.armoured, 7),
    ),
    'faille': (
      () => _units({_admiral: 1, _guardian: 6, _harpoonist: 40}),
      GuardianFactory.forFaille,
    ),
    'cheminee': (
      () => _units({_admiral: 2, _guardian: 10, _harpoonist: 90, _breaker: 10}),
      GuardianFactory.forCheminee,
    ),
    'volcanic kernel': (
      () => _units(
        {_admiral: 1, _guardian: 20, _harpoonist: 70, _breaker: 25},
        boost: _research,
      ),
      GuardianFactory.forVolcanicKernel,
    ),
    'krakens on a kernel': (
      () => [
        ..._units({_breaker: 20, _guardian: 10}),
        MagmaRampart.combatantFor(5)!,
      ],
      () => CombatantBuilder.monsterCombatantsFrom(
        VolcanoWaveFactory.fromKernelLevel(5),
      ),
    ),
    'leviathan returns': (
      () => LeviathanForce.combatants(monsterPercent: 94),
      () => _units(
        {_harpoonist: 18, _guardian: 6, _scout: 3},
        side: CombatSide.monster,
      ),
    ),
    'base against base': (
      () => _units({_harpoonist: 35, _saboteur: 6, _admiral: 1}, boost: _research),
      () => [
        ..._units({_guardian: 12, _harpoonist: 15}, side: CombatSide.monster),
        FightSides.onMonsterSide(CoralCitadelRampart.combatantFor(2)!),
      ],
    ),
  };

  static const _units = FightSides.units, _lair = FightSides.lair;
}
