import 'package:abyss/domain/building/building_base_costs.dart';
import 'package:abyss/domain/building/building_cost_calculator.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/exponential_cost.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import '../vector_file.dart';
import 'building_state_vectors.dart';

/// Costs, limits and requirements of every building at every level.
abstract final class BuildingVectors {
  static const _calculator = BuildingCostCalculator();

  /// No discount, Chantiers économes halved by a degraded laboratory,
  /// and in full.
  static const List<int> discounts = <int>[0, 7, 15];

  /// First-level costs `exponentialCost` grows: the buildings', the
  /// Citadel's and a research node's.
  static final List<Map<ResourceType, int>> bases = <Map<ResourceType, int>>[
    ...buildingBaseCosts.values,
    {ResourceType.coral: 250, ResourceType.ore: 250, ResourceType.energy: 125},
    {ResourceType.ore: 80, ResourceType.energy: 50},
  ];

  static final VectorFile file = VectorFile('buildings', {
    'exponentialCost': VectorSection(
      'exponentialCost(base, step) of resource/exponential_cost.dart: '
          '(base * pow(1.6, step)).round() for each resource',
      () => [
        for (final Map<ResourceType, int> base in bases)
          for (var step = 0; step <= 9; step++)
            {
              'base': base,
              'step': step,
              'out': exponentialCost(base, step),
            },
      ],
    ),
    'upgradeCost': VectorSection(
      'BuildingCostCalculator(discountPercent: discount)'
          '.upgradeCost(type, level), level being the current one; '
          'nothing at the maximum level',
      () => [
        for (final BuildingType type in BuildingType.values)
          for (var level = 0; level <= _calculator.maxLevel(type); level++)
            for (final int discount in discounts)
              {
                'type': type,
                'level': level,
                'discount': discount,
                'out': BuildingCostCalculator(
                  discountPercent: discount,
                ).upgradeCost(type, level),
              },
      ],
    ),
    'limits': VectorSection(
      'BuildingCostCalculator(): maxLevel(type), requiredCapturedBase'
          '(type), requiresCapturedKernel(type), and prerequisites(type, '
          'target) for target = 0 to maxLevel + 1 in that order',
      () => [
        for (final BuildingType type in BuildingType.values)
          {
            'type': type,
            'out': {
              'maxLevel': _calculator.maxLevel(type),
              'capturedBase': _calculator.requiredCapturedBase(type),
              'capturedKernel': _calculator.requiresCapturedKernel(type),
              'prerequisites': [
                for (var t = 0; t <= _calculator.maxLevel(type) + 1; t++)
                  _calculator.prerequisites(type, t),
              ],
            },
          },
      ],
    ),
    ...BuildingStateSections.sections,
  });
}
