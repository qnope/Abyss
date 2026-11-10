import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';

import '../vector_file.dart';

/// How hard the world presses: the krakens of a kernel, the strength of
/// the monsters at each difficulty, the noise of an upgrade.
abstract final class RaidPressureSections {
  static final Map<String, VectorSection> sections = {
    'krakens': VectorSection(
      'VolcanoWaveFactory.krakensFor(level, monsterPercent: percent, '
          'firstWave: firstWave); fromKernelLevel makes a hard wave of '
          'that many krakens',
      () => [
        for (var level = 0; level <= 10; level++)
          for (final int percent in const [100, 94, 86, 102, 70, 64, 30])
            for (final bool first in const [false, true])
              {
                'level': level,
                'percent': percent,
                'firstWave': first,
                'out': VolcanoWaveFactory.krakensFor(
                  level,
                  monsterPercent: percent,
                  firstWave: first,
                ),
              },
      ],
    ),
    'monsterPercent': VectorSection(
      'Of a Difficulty: resourcePercent, factionPercent, attackGap, '
          'monsterPercentFor(faction: true), and monsterPercentFor('
          'faction: false, factions: n) for n = 0 to 10; relief is '
          'Difficulty.worldReliefPercent(n) for the same n',
      () => [
        for (final Difficulty d in Difficulty.values)
          {
            'difficulty': d,
            'out': {
              'resourcePercent': d.resourcePercent,
              'factionPercent': d.factionPercent,
              'attackGap': d.attackGap,
              'faction': d.monsterPercentFor(faction: true),
              'human': [
                for (var n = 0; n <= 10; n++)
                  d.monsterPercentFor(faction: false, factions: n),
              ],
              'relief': [
                for (var n = 0; n <= 10; n++) Difficulty.worldReliefPercent(n),
              ],
            },
          },
      ],
    ),
    'upgradeNoise': VectorSection(
      'NoiseRules.forUpgrade(type, level)',
      () => [
        for (final BuildingType type in const [
          BuildingType.headquarters, BuildingType.volcanicKernel,
        ])
          for (final int level in const [1, 5, 10])
            {
              'type': type,
              'level': level,
              'out': NoiseRules.forUpgrade(type, level),
            },
      ],
    ),
  };
}
