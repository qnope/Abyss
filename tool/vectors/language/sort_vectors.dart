import '../vector_file.dart';
import 'sort_patterns.dart';

/// The order `List.sort` leaves elements in when its comparator ties:
/// the port's `DartSort`.
abstract final class SortVectors {
  static final VectorFile file = VectorFile('dart_sort', {
    'sort': VectorSection(
      'List.generate(keys.length, (i) => i)..sort(compare), compare(a, b) '
          'being keys[a].compareTo(keys[b]), or keys[b].compareTo(keys[a]) '
          'when descending; comparisons counts the calls of compare',
      () => [
        for (final int n in SortPatterns.lengths)
          for (final (String pattern, int? seed, List<int> keys)
              in SortPatterns.of(n))
            for (final bool descending in [
              false,
              if (n <= SortPatterns.descendingUpTo) true,
            ])
              {
                'pattern': pattern,
                if (seed != null) 'seed': seed,
                'descending': descending,
                'keys': keys,
                ...sorted(keys, descending: descending),
              },
      ],
    ),
    'natural': VectorSection(
      'List.of(values)..sort(), without comparator, as the rules sort '
          'cell indices and turn numbers',
      () => [
        for (final int n in const [0, 1, 7, 33, 34, 120])
          for (final (String pattern, int? seed, List<int> keys)
              in SortPatterns.of(n))
            if (seed != SortPatterns.seeds.last)
              {
                'pattern': pattern,
                if (seed != null) 'seed': seed,
                'values': keys,
                'out': List<int>.of(keys)..sort(),
              },
      ],
    ),
  });

  /// The indices of [keys] in the order `List.sort` leaves them, and
  /// how many times it compared two of them.
  static Map<String, Object> sorted(
    List<int> keys, {
    required bool descending,
  }) {
    var comparisons = 0;
    final List<int> order = List<int>.generate(keys.length, (i) => i)
      ..sort((a, b) {
        comparisons++;
        return descending
            ? keys[b].compareTo(keys[a])
            : keys[a].compareTo(keys[b]);
      });
    return {'out': order, 'comparisons': comparisons};
  }
}
