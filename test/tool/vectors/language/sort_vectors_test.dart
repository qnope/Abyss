import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/language/sort_patterns.dart';
import '../../../../tool/vectors/language/sort_vectors.dart';
import '../spec/dart_sort_spec.dart';

List<Map<String, Object?>> _cases(String section) =>
    SortVectors.file.sections[section]!.cases().cast<Map<String, Object?>>();

/// The specification's sort of [keys]: the order, the comparisons, and
/// the branches it went through.
(List<int>, int, Set<String>) _specSort(List<int> keys, bool descending) {
  var comparisons = 0;
  final spec = DartSortSpec<int>(
    List<int>.generate(keys.length, (i) => i),
    (a, b) {
      comparisons++;
      return descending
          ? keys[b].compareTo(keys[a])
          : keys[a].compareTo(keys[b]);
    },
  )..sort();
  return (spec.a, comparisons, spec.visited);
}

void main() {
  group('SortPatterns', () {
    test('sort lists on both sides of the change of algorithm', () {
      expect(SortPatterns.lengths, containsAll([0, 1, 32, 33, 34, 35]));
      expect(SortPatterns.lengths.last, greaterThan(200));
    });

    test('give as many keys as asked, most patterns with equal ones', () {
      final patterns = SortPatterns.of(64).toList();
      expect(patterns, hasLength(7 + 6 * SortPatterns.seeds.length));
      final tied = patterns.where((p) => p.$3.toSet().length < 64);
      expect(tied.length, greaterThan(patterns.length - 6));
      for (final (_, _, keys) in patterns) {
        expect(keys, hasLength(64));
      }
    });
  });

  group('SortVectors', () {
    final cases = _cases('sort');

    test('record a permutation that is sorted', () {
      for (final c in cases) {
        final keys = c['keys']! as List<int>;
        final out = c['out']! as List<int>;
        expect(out.toSet(), hasLength(keys.length));
        final sign = c['descending']! as bool ? -1 : 1;
        for (var i = 1; i < out.length; i++) {
          expect(sign * keys[out[i - 1]].compareTo(keys[out[i]]), isNot(1));
        }
      }
    });

    test('hold orders a stable sort would not give', () {
      bool stable(Map<String, Object?> c) {
        final keys = c['keys']! as List<int>;
        final out = c['out']! as List<int>;
        for (var i = 1; i < out.length; i++) {
          if (keys[out[i - 1]] == keys[out[i]] && out[i - 1] > out[i]) {
            return false;
          }
        }
        return true;
      }

      final unstable = cases.where((c) => !stable(c));
      expect(unstable, isNotEmpty);
      // Up to 33 elements the insertion sort keeps equal ones in order.
      expect(unstable.map((c) => (c['keys']! as List).length).toSet(), {
        ...SortPatterns.lengths.where((n) => n > 33),
      });
    });

    test('are what the specification gives, comparison for comparison', () {
      final visited = <String>{};
      for (final c in cases) {
        final (out, comparisons, branches) = _specSort(
          c['keys']! as List<int>,
          c['descending']! as bool,
        );
        final what = '${c['pattern']} ${c['seed']} ${(c['keys']! as List).length}';
        expect(out, c['out'], reason: what);
        expect(comparisons, c['comparisons'], reason: what);
        visited.addAll(branches);
      }
      expect(visited, {
        'flag: smaller',
        'flag: larger at the end',
        'flag: triple exchange',
        'flag: swapped with an equal',
        'split: smaller',
        'split: larger at the end',
        'split: triple exchange',
        'split: swapped with a middle one',
        'middle: sorted as it is',
        'middle: pivots taken out',
        'take out: equal to pivot1',
        'take out: pivot2 at the end',
        'take out: swapped with the end',
      });
    });

    test('sort without comparator as the specification does', () {
      for (final c in _cases('natural')) {
        final values = c['values']! as List<int>;
        final spec = DartSortSpec<int>(
          List<int>.of(values),
          (a, b) => a.compareTo(b),
        )..sort();
        expect(c['out'], spec.a);
      }
    });
  });
}
