import 'dart:math';

/// Keys to sort, many of them equal: the order `List.sort` leaves equal
/// elements in is what the port must reproduce.
abstract final class SortPatterns {
  /// Patterns that need no dice, by name: the key at [i] of [n].
  static final Map<String, int Function(int i, int n)> fixed = {
    'sorted': (i, n) => i,
    'sortedTies': (i, n) => i ~/ 3,
    'reversed': (i, n) => n - 1 - i,
    'reversedTies': (i, n) => (n - 1 - i) ~/ 3,
    'equal': (i, n) => 0,
    'sawtooth': (i, n) => i % 7,
    'organPipe': (i, n) => min(i, n - 1 - i),
  };

  /// Patterns drawn with a seeded generator, by name: the [n] keys.
  static final Map<String, List<int> Function(Random random, int n)> drawn = {
    'twoKeys': (random, n) => _draw(n, () => random.nextInt(2)),
    'threeKeys': (random, n) => _draw(n, () => random.nextInt(3)),
    'tenKeys': (random, n) => _draw(n, () => random.nextInt(10)),
    'someTies': (random, n) => _draw(n, () => random.nextInt(n)),
    'noTie': (random, n) => List<int>.generate(n, (i) => i)..shuffle(random),
    'mostlyEqual': (random, n) => _draw(n, () {
      final int roll = random.nextInt(20);
      return roll == 0 ? 0 : (roll == 1 ? 9 : 5);
    }),
  };

  /// Seeds of the [drawn] patterns.
  static const List<int> seeds = <int>[1, 42];

  /// Below, at and above the 32 elements where the algorithm changes
  /// (see the README), up to a list it splits several times.
  static const List<int> lengths = <int>[
    0, 1, 2, 3, 5, 8, 16, 31, 32, 33, 34, 35, 48, 64, 100, 200, 500,
  ];

  /// Longest list also sorted in descending order.
  static const int descendingUpTo = 100;

  /// Every pattern for a list of [n] keys: its name, its seed if drawn,
  /// its keys.
  static Iterable<(String, int?, List<int>)> of(int n) sync* {
    for (final e in fixed.entries) {
      yield (e.key, null, List<int>.generate(n, (i) => e.value(i, n)));
    }
    for (final e in drawn.entries) {
      for (final int seed in seeds) {
        yield (e.key, seed, e.value(Random(seed), n));
      }
    }
  }

  static List<int> _draw(int n, int Function() key) =>
      List<int>.generate(n, (_) => key());
}
