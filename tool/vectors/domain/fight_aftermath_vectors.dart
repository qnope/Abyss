import 'dart:math';

import 'package:abyss/domain/action/fight_monster_helpers.dart';
import 'package:abyss/domain/action/treasure_loot.dart';
import 'package:abyss/domain/fight/casualty_calculator.dart';
import 'package:abyss/domain/fight/casualty_split.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/loot_calculator.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../vector_file.dart';

/// What a fight leaves: the wounded, the dead and the loot.
abstract final class FightAftermathVectors {
  static const List<int> seeds = <int>[0, 1, 2, 42, 1000, 2147483646];

  /// Shares of the hit points lost, around the two bends of the curve.
  static final List<double> _lost = <double>[
    for (var k = 0; k <= 20; k++) k / 20,
    0.5000000000000001, 0.7999999999999999, 0.51, 0.65, 0.79, 1 / 3, 2 / 3,
  ];

  /// The fallen, by type key: scouts always come back wounded.
  static const List<List<UnitType>> _fallen = <List<UnitType>>[
    [],
    [UnitType.scout, UnitType.scout, UnitType.scout],
    [UnitType.harpoonist],
    [
      UnitType.scout, UnitType.harpoonist, UnitType.guardian,
      UnitType.domeBreaker, UnitType.abyssAdmiral, UnitType.saboteur,
      UnitType.scout, UnitType.harpoonist, UnitType.harpoonist,
      UnitType.guardian, UnitType.harpoonist, UnitType.saboteur,
    ],
  ];

  static final VectorFile file = VectorFile('fight_aftermath', {
    'woundedProbability': VectorSection(
      'CasualtyCalculator.woundedProbability(pctLost)',
      () => [
        for (final double lost in _lost)
          {
            'pctLost': lost,
            'out': CasualtyCalculator.woundedProbability(lost),
          },
      ],
    ),
    'pctLost': VectorSection(
      'FightMonsterHelpers.computePctLost(initial, finalC): the maxHp of '
          'initial are maxHp, the currentHp of finalC are left',
      () => [
        for (final (List<int> maxHp, List<int> left) in const [
          (<int>[], <int>[]),
          ([15], [15]),
          ([15], [0]),
          ([15, 15, 25], [15, 0, 5]),
          ([10, 10, 10], [1, 2, 3]),
          ([100, 15, 15, 15, 25, 25], [100, 0, 0, 7, 25, 3]),
          ([14, 14, 14], [0, 0, 14]),
        ])
          {
            'maxHp': maxHp,
            'left': left,
            'out': FightMonsterHelpers.computePctLost(
              [for (final int hp in maxHp) _unit('harpoonist', hp, hp)],
              [for (var i = 0; i < left.length; i++)
                _unit('harpoonist', maxHp[i], left[i])],
            ),
          },
      ],
    ),
    'casualties': VectorSection(
      'CasualtyCalculator(random: Random(seed)).partition(fallen, '
          'pctLost), fallen being a player Combatant per type key, in '
          'order: the type keys of wounded, then of dead',
      () => [
        for (final List<UnitType> fallen in _fallen)
          for (final double lost in const [0.2, 0.5, 0.65, 0.8, 1.0])
            for (final int seed in seeds.take(fallen.length < 4 ? 2 : 6))
              {
                'fallen': fallen,
                'pctLost': lost,
                'seed': seed,
                'out': _split(fallen, lost, seed),
              },
      ],
    ),
    'lairLoot': VectorSection(
      'LootCalculator(random: Random(seed)).compute(difficulty)',
      () => [
        for (final MonsterDifficulty d in MonsterDifficulty.values)
          for (final int seed in seeds)
            {
              'difficulty': d,
              'seed': seed,
              'out': LootCalculator(random: Random(seed)).compute(d),
            },
      ],
    ),
    'treasureLoot': VectorSection(
      'TreasureLoot.of(content, Random(seed), level)',
      () => [
        for (final CellContentType content in const [
          CellContentType.resourceBonus,
          CellContentType.ruins,
          CellContentType.wreck,
          CellContentType.empty,
          CellContentType.monsterLair,
        ])
          for (var level = 1; level <= 3; level++)
            for (final int seed in seeds)
              {
                'content': content,
                'level': level,
                'seed': seed,
                'out': TreasureLoot.of(content, Random(seed), level),
              },
      ],
    ),
  });

  static Combatant _unit(String typeKey, int maxHp, int currentHp) => Combatant(
    side: CombatSide.player,
    typeKey: typeKey,
    maxHp: maxHp,
    atk: 1,
    def: 1,
    currentHp: currentHp,
  );

  static Map<String, Object?> _split(
    List<UnitType> fallen,
    double pctLost,
    int seed,
  ) {
    final CasualtySplit split = CasualtyCalculator(
      random: Random(seed),
    ).partition([for (final t in fallen) _unit(t.name, 10, 0)], pctLost);
    return {
      'wounded': [for (final c in split.wounded) c.typeKey],
      'dead': [for (final c in split.dead) c.typeKey],
    };
  }
}
