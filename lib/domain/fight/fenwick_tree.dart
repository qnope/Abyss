/// Binary indexed tree over [size] positions holding integer counts.
///
/// Point updates, prefix sums and the lookup of the position holding the
/// n-th unit of count all run in O(log size), which keeps a random pick
/// among a shrinking set cheap without rebuilding a filtered list.
class FenwickTree {
  /// Number of positions, `0` to `size - 1`.
  final int size;

  /// Plain counts per position, for O(1) point reads.
  final List<int> _counts;

  /// Fenwick nodes, 1-based.
  final List<int> _nodes;

  /// Largest power of two at most [size]: the first lifting step.
  final int _topStep;

  int _total = 0;

  FenwickTree(this.size)
      : _counts = List<int>.filled(size, 0),
        _nodes = List<int>.filled(size + 1, 0),
        _topStep = size == 0 ? 0 : 1 << (size.bitLength - 1);

  /// Sum of every count.
  int get total => _total;

  /// Count held at [position].
  int at(int position) => _counts[position];

  /// Adds [delta] to the count at [position].
  void add(int position, int delta) {
    _counts[position] += delta;
    _total += delta;
    for (int i = position + 1; i <= size; i += i & -i) {
      _nodes[i] += delta;
    }
  }

  /// Sum of the counts at positions strictly before [end].
  int prefix(int end) {
    int sum = 0;
    for (int i = end; i > 0; i -= i & -i) {
      sum += _nodes[i];
    }
    return sum;
  }

  /// Position holding the [n]-th unit of count, 0-based: the first one
  /// whose prefix sum exceeds [n]. [n] must be below [total].
  int positionOfNth(int n) {
    int position = 0;
    int remaining = n + 1;
    for (int step = _topStep; step > 0; step >>= 1) {
      final int next = position + step;
      if (next <= size && _nodes[next] < remaining) {
        position = next;
        remaining -= _nodes[next];
      }
    }
    return position;
  }
}
