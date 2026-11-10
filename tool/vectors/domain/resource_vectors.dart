import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/resource/consumption_calculator.dart';
import 'package:abyss/domain/resource/production_calculator.dart';
import 'package:abyss/domain/resource/production_formulas.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';

import '../vector_file.dart';
import 'resource_cases.dart';
import 'resource_stock_vectors.dart';
import 'vector_inputs.dart';

/// Production per building and level, energy and storage.
abstract final class ResourceVectors {
  static final VectorFile file = VectorFile('resources', {
    'buildingProduction': VectorSection(
      'productionFormulas[type]: its resourceType and compute(level)',
      () => [
        for (final e in productionFormulas.entries)
          for (var level = -1; level <= 10; level++)
            {
              'type': e.key,
              'level': level,
              'out': {
                'resource': e.value.resourceType,
                'amount': e.value.compute(level),
              },
            },
      ],
    ),
    'production': VectorSection(
      'ProductionCalculator.fromBuildings(buildings, techBranches: tech); '
          'buildings as in buildings.json, tech = {branch: [level, '
          'choices]} for the unlocked branches (the others locked), or '
          'no techBranches when tech is null. scaled is '
          'Difficulty.<difficulty>.scaleProduction(out, faction: '
          'faction) for each difficulty, a human then a faction',
      () => [
        for (final c in ResourceCases.bases)
          {
            'buildings': c.$1,
            'tech': c.$2 == null ? null : VectorInputs.techJson(c.$2!),
            'out': _production(c.$1, c.$2),
            'scaled': {
              for (final Difficulty d in Difficulty.values)
                d: [
                  for (final bool faction in const [false, true])
                    d.scaleProduction(
                      _production(c.$1, c.$2),
                      faction: faction,
                    ),
                ],
            },
          },
      ],
    ),
    'energyConsumption': VectorSection(
      'ConsumptionCalculator.buildingEnergyConsumption(type, level)',
      () => [
        for (final BuildingType type in BuildingType.values)
          for (var level = 0; level <= 10; level += level < 5 ? 1 : 5)
            {
              'type': type,
              'level': level,
              'out': ConsumptionCalculator.buildingEnergyConsumption(
                type,
                level,
              ),
            },
      ],
    ),
    'totalConsumption': VectorSection(
      'ConsumptionCalculator.totalBuildingConsumption(buildings, '
          'excluded: excluded)',
      () => [
        for (final c in ResourceCases.bases)
          for (final Set<BuildingType>? excluded in const [
            null,
            {BuildingType.oreExtractor, BuildingType.laboratory},
          ])
            {
              'buildings': c.$1,
              'excluded': excluded,
              'out': ConsumptionCalculator.totalBuildingConsumption(
                VectorInputs.buildings(c.$1),
                excluded: excluded,
              ),
            },
      ],
    ),
    ...ResourceStockSections.sections,
  });

  static Map<ResourceType, int> _production(
    Map<BuildingType, int> levels,
    Map<TechBranch, (int, List<int>)>? research,
  ) => ProductionCalculator.fromBuildings(
    VectorInputs.buildings(levels),
    techBranches: research == null ? null : VectorInputs.tech(research),
  );
}
