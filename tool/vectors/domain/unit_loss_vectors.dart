import 'package:abyss/domain/resource/consumption_calculator.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_loss_calculator.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../vector_file.dart';
import 'vector_inputs.dart';

/// The units lost when the algae run short.
abstract final class UnitLossSections {
  static const List<Map<UnitType, int>> _armies = <Map<UnitType, int>>[
    {},
    {UnitType.scout: 1},
    {UnitType.scout: 3, UnitType.harpoonist: 10},
    {UnitType.harpoonist: 7, UnitType.guardian: 3, UnitType.abyssAdmiral: 1},
    {
      UnitType.scout: 12,
      UnitType.harpoonist: 40,
      UnitType.guardian: 15,
      UnitType.domeBreaker: 9,
      UnitType.abyssAdmiral: 2,
      UnitType.saboteur: 5,
    },
  ];

  static const List<int> _algae = <int>[0, 1, 10, 33, 100, 1000];

  static final Map<String, VectorSection> sections = {
    'hungerLosses': VectorSection(
      'UnitLossCalculator.calculateLosses(units: units, algaeProduction: '
          'production, algaeStock: 0), units holding the six types in '
          'the order of UnitType; upkeep is ConsumptionCalculator'
          '.totalUnitConsumption(units)',
      () => [
        for (final Map<UnitType, int> army in _armies)
          for (final int production in _algae)
            {
              'units': army,
              'production': production,
              'upkeep': ConsumptionCalculator.totalUnitConsumption(
                VectorInputs.units(army),
              ),
              'out': UnitLossCalculator.calculateLosses(
                units: VectorInputs.units(army),
                algaeProduction: production,
                algaeStock: 0,
              ),
            },
      ],
    ),
    'hungerLossesAllLevels': VectorSection(
      'UnitLossCalculator.applyLossesAllLevels(unitsPerLevel: {1: first, '
          '2: second}, algaeProduction: production, algaeStock: stock): '
          'the losses, then the units left on each level; '
          'calculateLossesAllLevels gives the same losses',
      () => [
        for (var i = 1; i < _armies.length; i++)
          for (final int production in _algae)
            _allLevels(_armies[i], _armies[i - 1], production, 7),
      ],
    ),
  };

  static Map<String, Object?> _allLevels(
    Map<UnitType, int> first,
    Map<UnitType, int> second,
    int production,
    int stock,
  ) {
    final Map<int, Map<UnitType, Unit>> levels = {
      1: VectorInputs.units(first),
      2: VectorInputs.units(second),
    };
    final Map<UnitType, int> preview =
        UnitLossCalculator.calculateLossesAllLevels(
          unitsPerLevel: levels,
          algaeProduction: production,
          algaeStock: stock,
        );
    final Map<UnitType, int> losses = UnitLossCalculator.applyLossesAllLevels(
      unitsPerLevel: levels,
      algaeProduction: production,
      algaeStock: stock,
    );
    if ('$preview' != '$losses') throw StateError('preview differs');
    return {
      'first': first,
      'second': second,
      'production': production,
      'stock': stock,
      'out': {
        'losses': losses,
        'left': [
          for (final units in levels.values)
            {for (final u in units.values) u.type: u.count},
        ],
      },
    };
  }
}
