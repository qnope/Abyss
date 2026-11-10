import 'dart:math';

import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/defence_strength.dart';
import 'package:abyss/domain/raid/raid_spoils.dart';
import 'package:abyss/domain/raid/raid_wave_factory.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import '../vector_file.dart';
import 'raid_cases.dart';
import 'raid_pressure_vectors.dart';
import 'vector_inputs.dart';

/// The monster waves that strike a base or a kernel, and their spoils.
abstract final class RaidVectors {
  static const String _wave =
      'a wave is [difficulty, family, unitCount, secondFamily, secondCount]';

  static final VectorFile file = VectorFile('raids', {
    'wave': VectorSection(
      'RaidWaveFactory.fromTotalNoise(noise, random: Random(seed), '
          'monsterPercent: percent, defenceStrength: defence); $_wave',
      () => [
        for (final (int noise, int percent, int defence) in RaidCases.waves)
          for (final int seed in RaidCases.seeds)
            {
              'noise': noise,
              'percent': percent,
              'defence': defence,
              'seed': seed,
              'out': wave(
                RaidWaveFactory.fromTotalNoise(
                  noise,
                  random: Random(seed),
                  monsterPercent: percent,
                  defenceStrength: defence,
                ),
              ),
            },
      ],
    ),
    'everyWave': VectorSection(
      'RaidWaveFactory.everyFromTotalNoise(noise, monsterPercent: '
          'percent), in order; $_wave',
      () => [
        for (final (int noise, int percent) in const [
          (0, 100), (40, 100), (90, 94), (200, 100), (400, 102),
        ])
          {
            'noise': noise,
            'percent': percent,
            'out': [
              for (final MonsterLair lair in RaidWaveFactory.everyFromTotalNoise(
                noise,
                monsterPercent: percent,
              ))
                wave(lair),
            ],
          },
      ],
    ),
    'defenceStrength': VectorSection(
      'DefenceStrength.of(player), units being those of the player on '
          'level 1',
      () => [
        for (final units in RaidCases.garrisons)
          {
            'units': units,
            'out': DefenceStrength.of(
              Player(
                name: 'defender',
                id: 'defender',
                unitsPerLevel: {1: VectorInputs.units(units)},
              ),
            ),
          },
      ],
    ),
    'loot': VectorSection(
      'RaidSpoils.loot(difficulty, random: Random(seed), percent: '
          'percent); capped is RaidSpoils.capToProduction(out, production)',
      () => [
        for (final MonsterDifficulty d in MonsterDifficulty.values)
          for (final int percent in const [100, 50, 33])
            for (final int seed in RaidCases.seeds.take(3))
              {
                'difficulty': d,
                'percent': percent,
                'seed': seed,
                'production': RaidCases.production,
                'out': RaidSpoils.loot(
                  d,
                  random: Random(seed),
                  percent: percent,
                ),
                'capped': RaidSpoils.capToProduction(
                  RaidSpoils.loot(d, random: Random(seed), percent: percent),
                  RaidCases.production,
                ),
              },
      ],
    ),
    'pillage': VectorSection(
      'RaidSpoils.pillage(resources, rate: rate): what was taken, then '
          'the stocks left; resources as in resources.json',
      () => [
        for (final Map<ResourceType, int> stocks in RaidCases.stocks)
          for (final double rate in const [0.3, 0.15, 0.225])
            {'stocks': stocks, 'rate': rate, 'out': _pillage(stocks, rate)},
      ],
    ),
    ...RaidPressureSections.sections,
  });

  static List<Object?> wave(MonsterLair lair) => [
    lair.difficulty, lair.family, lair.unitCount,
    lair.secondFamily, lair.secondCount,
  ];

  static Map<String, Object?> _pillage(Map<ResourceType, int> stocks, double rate) {
    final resources = VectorInputs.resources(stocks);
    return {
      'taken': RaidSpoils.pillage(resources, rate: rate),
      'left': {for (final r in resources.values) r.type: r.amount},
    };
  }
}
