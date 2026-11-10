part 'dart_sort_partitions.dart';

/// `List.sort` of the Dart SDK, written again from its
/// `sdk/lib/internal/sort.dart`, statement for statement: the
/// specification of the port's `DartSort`, kept true by the vectors (see
/// `reference/vectors/README.md`). [visited] names the branches a sort
/// went through, to tell what the vectors exercise.
class DartSortSpec<E> {
  /// A range of up to 33 elements (`right - left <= 32`) is sorted by
  /// insertion, a longer one by a dual-pivot quicksort.
  static const int insertionThreshold = 32;

  final List<E> a;
  final int Function(E a, E b) compare;
  final Set<String> visited = <String>{};

  DartSortSpec(this.a, this.compare);

  void sort() => _doSort(0, a.length - 1);

  void _doSort(int left, int right) {
    if (right - left <= insertionThreshold) {
      _insertionSort(left, right);
    } else {
      _dualPivotQuicksort(left, right);
    }
  }

  /// Stable: an element only moves before the ones it is smaller than.
  void _insertionSort(int left, int right) {
    for (int i = left + 1; i <= right; i++) {
      final E el = a[i];
      int j = i;
      while (j > left && compare(a[j - 1], el) > 0) {
        a[j] = a[j - 1];
        j--;
      }
      a[j] = el;
    }
  }

  void _dualPivotQuicksort(int left, int right) {
    final int sixth = (right - left + 1) ~/ 6;
    final int index1 = left + sixth;
    final int index5 = right - sixth;
    final int index3 = (left + right) ~/ 2;
    final int index2 = index3 - sixth;
    final int index4 = index3 + sixth;
    final List<E> five = _sortedFive(<E>[
      a[index1], a[index2], a[index3], a[index4], a[index5],
    ]);
    final E pivot1 = five[1];
    final E pivot2 = five[3];
    a[index1] = five[0];
    a[index3] = five[2];
    a[index5] = five[4];
    a[index2] = a[left];
    a[index4] = a[right];

    int less = left + 1;
    int great = right - 1;
    final bool pivotsAreEqual = compare(pivot1, pivot2) == 0;
    (less, great) = pivotsAreEqual
        ? _flagAround(pivot1, less, great)
        : _splitBetween(pivot1, pivot2, less, great);

    a[left] = a[less - 1];
    a[less - 1] = pivot1;
    a[right] = a[great + 1];
    a[great + 1] = pivot2;
    _doSort(left, less - 2);
    _doSort(great + 2, right);
    if (pivotsAreEqual) return;

    if (less < index1 && great > index5) {
      visited.add('middle: pivots taken out');
      while (compare(a[less], pivot1) == 0) {
        less++;
      }
      while (compare(a[great], pivot2) == 0) {
        great--;
      }
      (less, great) = _takeOutPivots(pivot1, pivot2, less, great);
    } else {
      visited.add('middle: sorted as it is');
    }
    _doSort(less, great);
  }

  /// The five samples through the SDK's sorting network: nine
  /// compare-and-swaps, in this order.
  List<E> _sortedFive(List<E> el) {
    const List<(int, int)> network = <(int, int)>[
      (0, 1), (3, 4), (0, 2), (1, 2), (0, 3), (2, 3), (1, 4), (1, 2), (3, 4),
    ];
    for (final (int i, int j) in network) {
      if (compare(el[i], el[j]) > 0) {
        final E t = el[i];
        el[i] = el[j];
        el[j] = t;
      }
    }
    return el;
  }
}
