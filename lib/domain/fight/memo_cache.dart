import 'dart:collection';

/// Remembers the last [capacity] answers of a costly pure computation,
/// forgetting the least recently used first. Lets a screen ask the same
/// question at every rebuild, or go back and forth between a few inputs,
/// without paying for it again.
class MemoCache<K, V> {
  final int capacity;
  final LinkedHashMap<K, V> _answers = LinkedHashMap<K, V>();

  MemoCache({this.capacity = 32}) : assert(capacity > 0);

  /// Number of answers remembered.
  int get length => _answers.length;

  /// The answer for [key], computed by [compute] when not remembered.
  V get(K key, V Function() compute) {
    if (_answers.containsKey(key)) {
      final V answer = _answers.remove(key) as V;
      return _answers[key] = answer;
    }
    final V answer = compute();
    _answers[key] = answer;
    if (_answers.length > capacity) _answers.remove(_answers.keys.first);
    return answer;
  }
}
