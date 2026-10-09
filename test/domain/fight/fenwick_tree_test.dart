import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/fenwick_tree.dart';

/// A tree of [size] positions holding a 1 at each of [ones].
FenwickTree _withOnes(int size, List<int> ones) {
  final FenwickTree tree = FenwickTree(size);
  for (final int position in ones) {
    tree.add(position, 1);
  }
  return tree;
}

/// A tree built with one `add` per non-zero entry of [counts].
FenwickTree _added(List<int> counts) {
  final FenwickTree tree = FenwickTree(counts.length);
  for (int position = 0; position < counts.length; position++) {
    if (counts[position] != 0) tree.add(position, counts[position]);
  }
  return tree;
}

/// Checks [a] and [b] agree on every read.
void _expectSame(FenwickTree a, FenwickTree b) {
  expect(a.size, b.size);
  expect(a.total, b.total);
  for (int end = 0; end <= a.size; end++) {
    expect(a.prefix(end), b.prefix(end), reason: 'prefix($end)');
  }
  for (int position = 0; position < a.size; position++) {
    expect(a.at(position), b.at(position), reason: 'at($position)');
  }
  for (int n = 0; n < a.total; n++) {
    expect(a.positionOfNth(n), b.positionOfNth(n), reason: 'nth($n)');
  }
}

void main() {
  group('FenwickTree', () {
    test('starts empty', () {
      final FenwickTree tree = FenwickTree(8);
      expect(tree.total, 0);
      expect(tree.prefix(8), 0);
      expect(tree.at(3), 0);
    });

    test('add updates total, prefix sums and point counts', () {
      final FenwickTree tree = _withOnes(8, <int>[1, 3, 4, 7]);

      expect(tree.total, 4);
      expect(tree.prefix(0), 0);
      expect(tree.prefix(1), 0);
      expect(tree.prefix(2), 1);
      expect(tree.prefix(4), 2);
      expect(tree.prefix(5), 3);
      expect(tree.prefix(8), 4);
      expect(tree.at(3), 1);
      expect(tree.at(2), 0);
    });

    test('positionOfNth walks a pattern with gaps in order', () {
      final FenwickTree tree = _withOnes(8, <int>[1, 3, 4, 7]);

      expect(tree.positionOfNth(0), 1);
      expect(tree.positionOfNth(1), 3);
      expect(tree.positionOfNth(2), 4);
      expect(tree.positionOfNth(3), 7);
    });

    test('positionOfNth skips removed positions', () {
      final FenwickTree tree = _withOnes(8, <int>[1, 3, 4, 7]);

      tree.add(3, -1);

      expect(tree.total, 3);
      expect(tree.prefix(4), 1);
      expect(tree.at(3), 0);
      expect(tree.positionOfNth(0), 1);
      expect(tree.positionOfNth(1), 4);
      expect(tree.positionOfNth(2), 7);
    });

    test('works on a size that is not a power of two', () {
      final List<int> all = List<int>.generate(13, (int i) => i);
      final FenwickTree tree = _withOnes(13, all);

      for (final int position in all) {
        expect(tree.positionOfNth(position), position);
        expect(tree.prefix(position), position);
      }
      expect(tree.positionOfNth(12), 12);
    });

    test('counts above one are summed', () {
      final FenwickTree tree = FenwickTree(4);
      tree.add(2, 3);
      tree.add(0, 2);

      expect(tree.total, 5);
      expect(tree.at(2), 3);
      expect(tree.prefix(3), 5);
      expect(tree.positionOfNth(1), 0);
      expect(tree.positionOfNth(2), 2);
      expect(tree.positionOfNth(4), 2);
    });
  });

  group('FenwickTree.fromCounts', () {
    const List<int> gapped = <int>[0, 1, 0, 1, 1, 0, 0, 1];
    const List<int> odd = <int>[1, 0, 2, 1, 0, 0, 1, 1, 0, 3, 0, 1, 1];

    test('equals a tree built with add on a gapped pattern', () {
      _expectSame(FenwickTree.fromCounts(gapped), _added(gapped));
    });

    test('equals a tree built with add on a size that is not a power of two',
        () {
      _expectSame(FenwickTree.fromCounts(odd), _added(odd));
    });

    test('keeps accepting updates', () {
      final FenwickTree built = FenwickTree.fromCounts(odd);
      final FenwickTree added = _added(odd);
      built.add(9, -2);
      added.add(9, -2);
      built.add(4, 1);
      added.add(4, 1);

      _expectSame(built, added);
    });

    test('does not share the counts it was given', () {
      final List<int> counts = <int>[1, 1];
      final FenwickTree tree = FenwickTree.fromCounts(counts);
      counts[0] = 5;

      expect(tree.at(0), 1);
      expect(tree.total, 2);
    });

    test('handles no positions', () {
      final FenwickTree tree = FenwickTree.fromCounts(const <int>[]);
      expect(tree.size, 0);
      expect(tree.total, 0);
    });
  });
}
