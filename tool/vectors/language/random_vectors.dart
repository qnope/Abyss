import 'dart:math';

import 'package:abyss/domain/replay/seeded_random.dart';

import '../vector_file.dart';
import 'random_seeds.dart';

/// What the Dart VM's `Random(seed)` draws: the port's `DartRandom`.
abstract final class RandomVectors {
  static const int _pow32 = 4294967296;

  /// Calls mixed on one generator, bounds of the game among them.
  static const List<Object> calls = <Object>[
    6, 'double', 'bool', 0x7FFFFFFF, 'double', 3, _pow32, 'bool', 'bool',
    100, 'double', 2147483649, 1, 'double', 'bool', 31, 400, 'double',
  ];

  static final VectorFile file = VectorFile('dart_random', {
    'nextInt': VectorSection(
      'Random(seed), then nextInt(max) 6 times',
      () => [
        for (final int seed in RandomSeeds.all)
          for (final int max in RandomSeeds.bounds)
            {'seed': seed, 'max': max, 'out': _ints(Random(seed), max, 6)},
      ],
    ),
    'nextDouble': VectorSection(
      'Random(seed), then nextDouble() 12 times',
      () => [
        for (final int seed in RandomSeeds.all)
          {'seed': seed, 'out': _doubles(Random(seed), 12)},
      ],
    ),
    'nextBool': VectorSection(
      'Random(seed), then nextBool() 40 times',
      () => [
        for (final int seed in RandomSeeds.all)
          {'seed': seed, 'out': _bools(Random(seed), 40)},
      ],
    ),
    'mixed': VectorSection(
      'Random(seed), then one call per entry of calls: nextInt(max) for '
          'a number, nextDouble() for "double", nextBool() for "bool"',
      () => [
        for (final int seed in RandomSeeds.all)
          {'seed': seed, 'calls': calls, 'out': play(Random(seed), calls)},
      ],
    ),
    'afterMany': VectorSection(
      'Random(seed), skip calls of nextInt(4294967296), then nextInt(max) '
          '6 times',
      () => [
        for (final int seed in RandomSeeds.few)
          for (final int skip in const [1000, 100000])
            for (final int max in const [_pow32, 0x7FFFFFFF, 6])
              {
                'seed': seed,
                'skip': skip,
                'max': max,
                'out': _ints(_skipped(seed, skip), max, 6),
              },
      ],
    ),
    'refused': VectorSection(
      'Random(seed).nextInt(max) throws a RangeError',
      () => [
        for (final int max in RandomSeeds.refused)
          {'seed': 1, 'max': max, 'throws': _throws(max)},
      ],
    ),
    'seededRandom': VectorSection(
      'SeededRandom(seed) of lib/domain/replay/seeded_random.dart: its '
          'seed, then the calls as in mixed',
      () => [
        for (final int seed in const [0, 1, 42, 2147483646, 20261110])
          {
            'seed': seed,
            'keptSeed': SeededRandom(seed).seed,
            'calls': calls,
            'out': play(SeededRandom(seed), calls),
          },
      ],
    ),
  });

  /// What [random] answers to each of [calls].
  static List<Object> play(Random random, List<Object> calls) => [
    for (final Object call in calls)
      switch (call) {
        'double' => random.nextDouble(),
        'bool' => random.nextBool(),
        final int max => random.nextInt(max),
        _ => throw ArgumentError.value(call, 'call'),
      },
  ];

  static List<int> _ints(Random random, int max, int count) => [
    for (var i = 0; i < count; i++) random.nextInt(max),
  ];

  static List<double> _doubles(Random random, int count) => [
    for (var i = 0; i < count; i++) random.nextDouble(),
  ];

  static List<bool> _bools(Random random, int count) => [
    for (var i = 0; i < count; i++) random.nextBool(),
  ];

  static Random _skipped(int seed, int skip) {
    final random = Random(seed);
    for (var i = 0; i < skip; i++) {
      random.nextInt(_pow32);
    }
    return random;
  }

  static bool _throws(int max) {
    try {
      Random(1).nextInt(max);
      return false;
    } on RangeError {
      return true;
    }
  }
}
