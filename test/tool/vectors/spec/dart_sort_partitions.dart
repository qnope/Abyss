part of 'dart_sort_spec.dart';

/// The three partition loops of the dual-pivot quicksort. Each returns
/// the new (less, great).
extension _Partitions<E> on DartSortSpec<E> {
  /// Equal pivots, a Dutch national flag: `< pivot | == pivot | > pivot`.
  (int, int) _flagAround(E pivot, int less, int great) {
    for (int k = less; k <= great; k++) {
      final E ak = a[k];
      int comp = compare(ak, pivot);
      if (comp == 0) continue;
      if (comp < 0) {
        if (k != less) {
          a[k] = a[less];
          a[less] = ak;
        }
        less++;
        visited.add('flag: smaller');
        continue;
      }
      while (true) {
        comp = compare(a[great], pivot);
        if (comp > 0) {
          great--;
          visited.add('flag: larger at the end');
          continue;
        }
        if (comp < 0) {
          a[k] = a[less];
          a[less++] = a[great];
          a[great--] = ak;
          visited.add('flag: triple exchange');
        } else {
          a[k] = a[great];
          a[great--] = ak;
          visited.add('flag: swapped with an equal');
        }
        break;
      }
    }
    return (less, great);
  }

  /// `< pivot1 | pivot1 <= .. <= pivot2 | > pivot2`.
  (int, int) _splitBetween(E pivot1, E pivot2, int less, int great) {
    for (int k = less; k <= great; k++) {
      final E ak = a[k];
      if (compare(ak, pivot1) < 0) {
        if (k != less) {
          a[k] = a[less];
          a[less] = ak;
        }
        less++;
        visited.add('split: smaller');
      } else if (compare(ak, pivot2) > 0) {
        while (true) {
          if (compare(a[great], pivot2) > 0) {
            great--;
            visited.add('split: larger at the end');
            if (great < k) break;
            continue;
          }
          if (compare(a[great], pivot1) < 0) {
            a[k] = a[less];
            a[less++] = a[great];
            a[great--] = ak;
            visited.add('split: triple exchange');
          } else {
            a[k] = a[great];
            a[great--] = ak;
            visited.add('split: swapped with a middle one');
          }
          break;
        }
      }
    }
    return (less, great);
  }

  /// `== pivot1 | pivot1 < .. < pivot2 | == pivot2`, on a middle part
  /// that holds nothing outside the pivots. The SDK tests `< 0` where
  /// its comment says "triple exchange": with a comparator that does not
  /// lie that branch never runs, and an element equal to pivot1 found at
  /// the end stays in the middle. Kept as it is.
  (int, int) _takeOutPivots(E pivot1, E pivot2, int less, int great) {
    for (int k = less; k <= great; k++) {
      final E ak = a[k];
      if (compare(ak, pivot1) == 0) {
        if (k != less) {
          a[k] = a[less];
          a[less] = ak;
        }
        less++;
        visited.add('take out: equal to pivot1');
      } else if (compare(ak, pivot2) == 0) {
        while (true) {
          if (compare(a[great], pivot2) == 0) {
            great--;
            visited.add('take out: pivot2 at the end');
            if (great < k) break;
            continue;
          }
          if (compare(a[great], pivot1) < 0) {
            a[k] = a[less];
            a[less++] = a[great];
            a[great--] = ak;
            visited.add('take out: triple exchange');
          } else {
            a[k] = a[great];
            a[great--] = ak;
            visited.add('take out: swapped with the end');
          }
          break;
        }
      }
    }
    return (less, great);
  }
}
