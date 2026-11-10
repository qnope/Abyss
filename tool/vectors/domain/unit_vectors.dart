import 'package:abyss/domain/fight/combat_role.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/resource/consumption_calculator.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_cost_calculator.dart';
import 'package:abyss/domain/unit/unit_stats.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../vector_file.dart';
import 'unit_loss_vectors.dart';
import 'vector_inputs.dart';

/// Stats, costs and upkeep of every unit, and the units lost to hunger.
abstract final class UnitVectors {
  static final _costs = UnitCostCalculator();

  /// Every boost the research gives, whole or halved, and a few more.
  static const List<int> percents = <int>[
    0, 10, 17, 20, 27, 30, 35, 37, 40, 45, 47, 50, 55, 60, 65, 70, 75, 90,
    95, 110, 130,
  ];

  /// Every HP, ATK and DEF of a unit.
  static const List<int> stats = <int>[
    0, 1, 2, 3, 5, 6, 8, 10, 15, 20, 25, 100,
  ];

  static final VectorFile file = VectorFile('units', {
    'units': VectorSection(
      'For a UnitType: UnitStats.forType(type) as [hp, atk, def], '
          'CombatRole.forUnit(type), ConsumptionCalculator'
          '.unitAlgaeConsumption(type), and of UnitCostCalculator(): '
          'unlockLevel(type), recruitmentCost(type) and '
          'recruitmentCost(type, degraded: true)',
      () => [
        for (final UnitType type in UnitType.values)
          {
            'type': type,
            'out': {
              'stats': _stats(UnitStats.forType(type)),
              'role': CombatRole.forUnit(type),
              'algae': ConsumptionCalculator.unitAlgaeConsumption(type),
              'unlockLevel': _costs.unlockLevel(type),
              'cost': _costs.recruitmentCost(type),
              'costDegraded': _costs.recruitmentCost(type, degraded: true),
            },
          },
      ],
    ),
    'boost': VectorSection(
      'UnitBoost(atkPercent: percent).atk(stat); def and hp go through '
          'the same rounding',
      () => [
        for (final int percent in percents)
          {
            'percent': percent,
            'stats': stats,
            'out': [
              for (final int stat in stats)
                UnitBoost(atkPercent: percent).atk(stat),
            ],
          },
      ],
    ),
    'maxRecruitable': VectorSection(
      'UnitCostCalculator().maxRecruitableCount(type, barracks, '
          'resources, degraded: degraded), resources holding stock of '
          'each of the five resources',
      () => [
        for (final UnitType type in UnitType.values)
          for (final int stock in const [0, 9, 10, 45, 1000, 5000])
            for (final (int barracks, bool degraded) in const [
              (0, false), (1, false), (3, true), (5, false),
            ])
              {
                'type': type,
                'stock': stock,
                'barracks': barracks,
                'degraded': degraded,
                'out': _costs.maxRecruitableCount(
                  type,
                  barracks,
                  VectorInputs.resources({
                    for (final r in ResourceType.values) r: stock,
                  }),
                  degraded: degraded,
                ),
              },
      ],
    ),
    ...UnitLossSections.sections,
  });

  static List<int> _stats(UnitStats s) => [s.hp, s.atk, s.def];
}
