/// [items] sorted by ascending [depth], so that drawing them in this order
/// paints the nearer ones over the farther ones. Items at the same depth
/// keep their given order, so the drawing never flickers between frames.
List<T> backToFront<T>(Iterable<T> items, double Function(T item) depth) {
  final indexed = items.indexed.toList();
  indexed.sort((a, b) {
    final byDepth = depth(a.$2).compareTo(depth(b.$2));
    return byDepth != 0 ? byDepth : a.$1.compareTo(b.$1);
  });
  return [for (final (_, item) in indexed) item];
}
