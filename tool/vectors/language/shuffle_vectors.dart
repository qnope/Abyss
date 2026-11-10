import 'dart:math';

import '../vector_file.dart';
import 'random_seeds.dart';

/// What `List.shuffle(random)` does to a list: the only helper of
/// `dart:math` or `dart:collection` the rules feed a generator to.
abstract final class ShuffleVectors {
  /// Empty and tiny lists, the families of a raid (3 and 4), the ten
  /// personalities, both sides of a fight, the free cells of a map.
  static const List<int> lengths = <int>[
    0, 1, 2, 3, 4, 5, 6, 8, 10, 13, 16, 20, 32, 33, 52, 100, 375, 400,
  ];

  static final VectorFile file = VectorFile('dart_shuffle', {
    'shuffle': VectorSection(
      'List.generate(length, (i) => i)..shuffle(random) with '
          'random = Random(seed); next is random.nextInt(4294967296) '
          'once shuffled',
      () => [
        for (final int length in lengths)
          for (final int seed in RandomSeeds.few) _case(length, seed),
      ],
    ),
    'twice': VectorSection(
      'Two lists of 0..length-1 shuffled one after the other with the '
          'same Random(seed)',
      () => [
        for (final int seed in RandomSeeds.few)
          {
            'seed': seed,
            'length': 7,
            'out': _twice(Random(seed), 7),
          },
      ],
    ),
  });

  static Map<String, Object?> _case(int length, int seed) {
    final random = Random(seed);
    return {
      'seed': seed,
      'length': length,
      'out': _shuffled(random, length),
      'next': random.nextInt(4294967296),
    };
  }

  static List<int> _shuffled(Random random, int length) =>
      List<int>.generate(length, (i) => i)..shuffle(random);

  static List<List<int>> _twice(Random random, int length) => [
    _shuffled(random, length),
    _shuffled(random, length),
  ];
}
