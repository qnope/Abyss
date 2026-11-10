import 'package:abyss/domain/building/building_deactivator.dart';
import 'package:abyss/domain/building/building_degradation.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/building/coral_citadel_rampart.dart';
import 'package:abyss/domain/worksite/worksite_rules.dart';

import '../vector_file.dart';
import 'vector_inputs.dart';

/// What a base can do with its buildings as they stand: degraded ones,
/// the rampart, the worksites.
abstract final class BuildingStateSections {
  static final List<Map<BuildingType, int>> _bases = <Map<BuildingType, int>>[
    {},
    {BuildingType.headquarters: 1, BuildingType.algaeFarm: 1},
    {
      BuildingType.headquarters: 3,
      BuildingType.algaeFarm: 3,
      BuildingType.coralMine: 3,
      BuildingType.oreExtractor: 2,
      BuildingType.solarPanel: 3,
      BuildingType.laboratory: 2,
      BuildingType.barracks: 2,
      BuildingType.coralCitadel: 1,
    },
    {
      BuildingType.headquarters: 4,
      BuildingType.algaeFarm: 4,
      BuildingType.solarPanel: 5,
      BuildingType.laboratory: 3,
      BuildingType.barracks: 3,
      BuildingType.coralCitadel: 3,
      BuildingType.descentModule: 1,
    },
    {for (final type in BuildingType.values) type: 10},
  ];

  static final Map<String, VectorSection> sections = {
    'degradation': VectorSection(
      'With buildings = the levels given, 0 for the others, in the order '
          'of BuildingType: for each built type but the headquarters, '
          'BuildingDegradation.requiredHeadquarters(buildings, type) and '
          'missingHeadquarters(buildings, type); deactivated is '
          'BuildingDeactivator.deactivate(buildings, energyProduction: '
          '10, energyStock: 5)',
      () => [
        for (final Map<BuildingType, int> levels in _bases)
          {'buildings': levels, 'out': _degradation(levels)},
      ],
    ),
    'rampart': VectorSection(
      'CoralCitadelRampart.hpForLevel(level), defForLevel(level), and '
          'combatantFor(level, degraded: degraded) as [typeKey, side, '
          'maxHp, atk, def, currentHp, isBoss] or null',
      () => [
        for (var level = 0; level <= 5; level++)
          for (final bool degraded in const [false, true])
            {
              'level': level,
              'degraded': degraded,
              'out': {
                'hp': CoralCitadelRampart.hpForLevel(level),
                'def': CoralCitadelRampart.defForLevel(level),
                'combatant': switch (CoralCitadelRampart.combatantFor(
                  level,
                  degraded: degraded,
                )) {
                  null => null,
                  final c => VectorInputs.combatant(c),
                },
              },
            },
      ],
    ),
    'worksites': VectorSection(
      'WorksiteRules.buildSites(hq) and nextSiteAtHq(hq)',
      () => [
        for (var hq = 0; hq <= 10; hq++)
          {
            'hq': hq,
            'out': {
              'buildSites': WorksiteRules.buildSites(hq),
              'nextSiteAtHq': WorksiteRules.nextSiteAtHq(hq),
            },
          },
      ],
    ),
  };

  static Map<String, Object?> _degradation(Map<BuildingType, int> levels) {
    final buildings = VectorInputs.buildings(levels);
    return {
      'required': {
        for (final type in levels.keys.skip(1))
          type: BuildingDegradation.requiredHeadquarters(buildings, type),
      },
      'missing': {
        for (final type in levels.keys.skip(1))
          type: BuildingDegradation.missingHeadquarters(buildings, type),
      },
      'deactivated': BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 10,
        energyStock: 5,
      ),
    };
  }
}
