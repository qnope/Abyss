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
}
