import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/fight/monster_unit_stats.dart';
import 'package:abyss/domain/leviathan/leviathan_force.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/volcano/magma_rampart.dart';

import '../vector_file.dart';
import 'vector_inputs.dart';

/// The stats of the monsters and the forces the game fields by itself.
abstract final class FightForceSections {
  static const List<int> _counts = <int>[
    0, 1, 2, 5, 6, 9, 10, 20, 33, 50, 100, 200,
  ];

  static const List<MonsterFamily?> _families = <MonsterFamily?>[
    null, ...MonsterFamily.values,
  ];

  static final Map<String, VectorSection> sections = {
    'monsters': VectorSection(
      'For a family (null: the generic monsters): MonsterUnitStats'
          '.of(family, level) as [hp, atk, def] and MonsterFamily'
          '.typeKeyOf(family, level) for levels 1 to 3, family.isBoss, '
          'MonsterUnitStats.countPercent(family), and countFor(family, n) '
          'for each n of counts',
      () => [
        for (final MonsterFamily? family in _families)
          {
            'family': family,
            'counts': _counts,
            'out': _monster(family),
          },
      ],
    ),
    'monsterLevels': VectorSection(
      'MonsterUnitStats.levelFor(difficulty) and MonsterFamily'
          '.availableAt(level) for that level',
      () => [
        for (final MonsterDifficulty d in MonsterDifficulty.values)
          {
            'difficulty': d,
            'out': {
              'level': MonsterUnitStats.levelFor(d),
              'families': MonsterFamily.availableAt(
                MonsterUnitStats.levelFor(d),
              ),
            },
          },
      ],
    ),
    'guardians': VectorSection(
      'GuardianFactory.forFaille(), forCheminee() and '
          'forVolcanicKernel() as runs [typeKey, side, maxHp, atk, def, '
          'isBoss, count]',
      () => [
        {'of': 'faille', 'out': VectorInputs.runs(GuardianFactory.forFaille())},
        {
          'of': 'cheminee',
          'out': VectorInputs.runs(GuardianFactory.forCheminee()),
        },
        {
          'of': 'kernel',
          'out': VectorInputs.runs(GuardianFactory.forVolcanicKernel()),
        },
      ],
    ),
    'magmaRampart': VectorSection(
      'MagmaRampart.combatantFor(level) as a run, null when unbuilt',
      () => [
        for (var level = 0; level <= 10; level++)
          {
            'level': level,
            'out': switch (MagmaRampart.combatantFor(level)) {
              null => null,
              final c => VectorInputs.runs([c]).single,
            },
          },
      ],
    ),
    'leviathan': VectorSection(
      'LeviathanForce.combatants(monsterPercent: percent) as runs',
      () => [
        for (final int percent in const [100, 94, 86, 102, 91, 64, 76, 50])
          {
            'percent': percent,
            'out': VectorInputs.runs(
              LeviathanForce.combatants(monsterPercent: percent),
            ),
          },
      ],
    ),
  };

  static Map<String, Object?> _monster(MonsterFamily? family) => {
    'stats': [
      for (var level = 1; level <= 3; level++)
        switch (MonsterUnitStats.of(family, level)) {
          final s => [s.hp, s.atk, s.def],
        },
    ],
    'typeKeys': [
      for (var level = 1; level <= 3; level++)
        MonsterFamily.typeKeyOf(family, level),
    ],
    'isBoss': family?.isBoss ?? false,
    'countPercent': MonsterUnitStats.countPercent(family),
    'countFor': [
      for (final int n in _counts) MonsterUnitStats.countFor(family, n),
    ],
  };
}
