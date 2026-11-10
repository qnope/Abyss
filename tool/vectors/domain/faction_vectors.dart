import 'package:abyss/domain/faction/faction_catalogue.dart';
import 'package:abyss/domain/faction/faction_exploration.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_traits.dart';
import 'package:abyss/domain/faction/faction_war.dart';
import 'package:abyss/domain/faction/kernel_siege.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/map/grid_position.dart';

import '../vector_file.dart';
import '../vector_json.dart';

/// Which factions a game draws, how each one plays and when it strikes.
abstract final class FactionVectors {
  static const List<int> seeds = <int>[0, 1, 2, 42, 0x5FAC7, 2147483646];

  static const int _turns = 48;

  static final VectorFile file = VectorFile('factions', {
    'draw': VectorSection(
      'FactionCatalogue.draw(count, seed: seed)',
      () => [
        for (final int seed in seeds)
          for (final int count in const [1, 3, 10])
            {
              'seed': seed,
              'count': count,
              'out': FactionCatalogue.draw(count, seed: seed),
            },
      ],
    ),
    'traits': VectorSection(
      'FactionTraits.of(personality): every field, warMix as [type, '
          'count] in order, plus the personality\'s label and '
          'shareOn(turn) for turn = 0 to 29 (shares)',
      () => [
        for (final FactionPersonality p in FactionPersonality.values)
          {'personality': p, 'out': _traits(p)},
      ],
    ),
    'slots': VectorSection(
      'The turns from 0 to ${_turns - 1} where FactionWar.isDue(turn, '
          'personality) (due), FactionWar.isGrudgeSlot(turn, personality) '
          '(grudge) and KernelSiege.isOffSlot(turn, personality) (offSlot)',
      () => [
        for (final FactionPersonality p in FactionPersonality.values)
          {
            'personality': p,
            'out': {
              'due': _turnsWhere((t) => FactionWar.isDue(t, p)),
              'grudge': _turnsWhere((t) => FactionWar.isGrudgeSlot(t, p)),
              'offSlot': _turnsWhere((t) => KernelSiege.isOffSlot(t, p)),
            },
          },
      ],
    ),
    'siege': VectorSection(
      'p = KernelSiege.plannerFor(ArmyPlanner(rehearsals: 8, confidence: '
          'confidence), level): [p.rehearsals, p.confidence]; hot is '
          'KernelSiege.isHot(level)',
      () => [
        for (final double confidence in const [0.85, 0.8, 0.75, 0.7, 0.625, 0.5])
          for (final int level in const [0, 6, 7, 8, 10])
            {
              'confidence': confidence,
              'level': level,
              'hot': KernelSiege.isHot(level),
              'out': switch (KernelSiege.plannerFor(
                ArmyPlanner(confidence: confidence),
                level,
              )) {
                final p => [p.rehearsals, p.confidence],
              },
            },
      ],
    ),
    'siegesPerTurn': VectorSection(
      'KernelSiege.wonPerTurn(difficulty)',
      () => [
        for (final Difficulty d in Difficulty.values)
          {'difficulty': d, 'out': KernelSiege.wonPerTurn(d)},
      ],
    ),
    'explorationBias': VectorSection(
      'FactionExploration.bias(base: GridPosition(x: base[0], y: '
          'base[1]), width: size, height: size, target: GridPosition(x: '
          'target[0], y: target[1])) for each target of targets',
      () => [
        for (final (int size, int bx, int by) in const [
          (20, 3, 4), (20, 10, 9), (26, 22, 2), (32, 15, 16), (21, 0, 20),
        ])
          {
            'size': size,
            'base': [bx, by],
            'targets': _targets(size),
            'out': [
              for (final List<int> t in _targets(size))
                FactionExploration.bias(
                  base: GridPosition(x: bx, y: by),
                  width: size,
                  height: size,
                  target: GridPosition(x: t[0], y: t[1]),
                ),
            ],
          },
      ],
    ),
  });

  static List<int> _turnsWhere(bool Function(int turn) test) => [
    for (var turn = 0; turn < _turns; turn++)
      if (test(turn)) turn,
  ];

  static List<List<int>> _targets(int size) => [
    for (final int x in [0, 3, size ~/ 2 - 1, size ~/ 2, size - 4, size - 1])
      for (final int y in [0, 4, size ~/ 2, size - 1]) [x, y],
  ];

  static Map<String, Object?> _traits(FactionPersonality p) {
    final FactionTraits t = FactionTraits.of(p);
    return {
      'label': p.label,
      'cadence': t.cadence,
      'confidence': t.confidence,
      'grudgeEvery': t.grudgeEvery,
      'warMix': VectorJson.pairs(t.warMix),
      'warShare': t.warShare,
      'conquestShare': t.conquestShare,
      'defends': t.defends,
      'postsFirst': t.postsFirst,
      'rushUntil': t.rushUntil,
      'rushShare': t.rushShare,
      'kernelFirst': t.kernelFirst,
      'guardShare': t.guardShare,
      'explorers': t.explorers,
      'growth': t.growth,
      'planner': [t.planner.rehearsals, t.planner.confidence],
      'shares': [for (var turn = 0; turn < 30; turn++) t.shareOn(turn)],
    };
  }
}
